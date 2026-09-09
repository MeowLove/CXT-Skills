[CmdletBinding()]
param(
    [switch]$CheckOnly,
    [switch]$NoInstall,
    [switch]$Interactive,
    [switch]$Force,
    [switch]$DebugMode,
    [string]$InstallerArguments = '',
    [string]$DownloadDirectory = "$env:LOCALAPPDATA\DoubaoIme\OfficialUpdater"
)

Set-StrictMode -Version Latest
$ErrorActionPreference = 'Stop'
[Net.ServicePointManager]::SecurityProtocol = [Net.SecurityProtocolType]::Tls12

$ApiUrl = 'https://shurufa.doubao.com/api/v1/app/download_url?platform=windows'
$OfficialHost = 'lf-wave.doubaocdn.com'

function Write-Log([string]$Message) {
    Write-Host ('[{0}] {1}' -f (Get-Date -Format 'HH:mm:ss'), $Message)
}

function Write-DebugLog([string]$Message) {
    if ($DebugMode) { Write-Log $Message }
}

function ConvertTo-Version([string]$Value) {
    $parts = @($Value.Trim().TrimStart('v', 'V').Split('.') | Where-Object { $_ -match '^\d+$' })
    if ($parts.Count -lt 2 -or $parts.Count -gt 4) { throw "Invalid version: $Value" }
    while ($parts.Count -lt 4) { $parts += '0' }
    return [version]::new([int]$parts[0], [int]$parts[1], [int]$parts[2], [int]$parts[3])
}

function Get-InstalledVersion {
    $keys = @('HKLM:\SOFTWARE\DoubaoIme', 'HKLM:\SOFTWARE\WOW6432Node\DoubaoIme')
    foreach ($key in $keys) {
        try {
            $reg = Get-ItemProperty -Path $key
            if ($reg.VersionDir) {
                $versionFile = Join-Path ([string]$reg.VersionDir) 'version.dat'
                if (Test-Path -LiteralPath $versionFile) {
                    return [pscustomobject]@{
                        Version = ConvertTo-Version (Get-Content -LiteralPath $versionFile -Raw).Trim()
                        Directory = [string]$reg.VersionDir
                    }
                }
            }
        } catch { }
    }
    return [pscustomobject]@{ Version = [version]::new(0, 0, 0, 0); Directory = $null }
}

function Get-UninstallInfo {
    $roots = @(
        'HKLM:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKLM:\SOFTWARE\WOW6432Node\Microsoft\Windows\CurrentVersion\Uninstall',
        'HKCU:\SOFTWARE\Microsoft\Windows\CurrentVersion\Uninstall'
    )
    foreach ($root in $roots) {
        foreach ($key in @(Get-ChildItem -Path $root -ErrorAction SilentlyContinue)) {
            try {
                $item = Get-ItemProperty -LiteralPath $key.PSPath -ErrorAction Stop
                if (($item.DisplayName -match '(?i)Doubao') -or ($item.Publisher -match '(?i)Chuntian|Zhiyun') -or ($item.UninstallString -match '(?i)DoubaoIME')) {
                    return [pscustomobject]@{
                        DisplayName = [string]$item.DisplayName
                        UninstallString = [string]$item.UninstallString
                        QuietUninstallString = [string]$item.QuietUninstallString
                        RegistryPath = $key.PSPath
                    }
                }
            } catch { }
        }
    }
    return $null
}

function Split-CommandLine([string]$CommandLine) {
    if ([string]::IsNullOrWhiteSpace($CommandLine)) { throw 'Uninstall command is empty.' }
    $value = $CommandLine.Trim()
    if ($value.StartsWith('"')) {
        $end = $value.IndexOf('"', 1)
        if ($end -lt 0) { throw 'Uninstall command has an invalid quoted path.' }
        return [pscustomobject]@{ FilePath = $value.Substring(1, $end - 1); Arguments = $value.Substring($end + 1).Trim() }
    }
    $parts = $value.Split(@(' '), 2, [StringSplitOptions]::RemoveEmptyEntries)
    return [pscustomobject]@{ FilePath = $parts[0]; Arguments = if ($parts.Count -gt 1) { $parts[1] } else { '' } }
}

function Invoke-Uninstall([pscustomobject]$Info, [bool]$Quiet) {
    $commandLine = if ($Quiet -and -not [string]::IsNullOrWhiteSpace($Info.QuietUninstallString)) { $Info.QuietUninstallString } else { $Info.UninstallString }
    $command = Split-CommandLine $commandLine
    if (-not (Test-Path -LiteralPath $command.FilePath -PathType Leaf)) { throw "Uninstaller not found: $($command.FilePath)" }
    Write-Log "Starting official uninstaller: $($command.FilePath) $($command.Arguments)"
    $process = Start-Process -FilePath $command.FilePath -ArgumentList $command.Arguments -Wait -PassThru
    if ($process.ExitCode -ne 0) { throw "Uninstaller exited with code $($process.ExitCode)" }
    Start-Sleep -Seconds 2
    $remaining = Get-UninstallInfo
    $service = Get-Process -Name ImeService -ErrorAction SilentlyContinue
    if ($remaining -or $service) { throw 'Uninstaller completed, but Doubao IME still appears to be installed or running.' }
    Write-Log 'Uninstall completed and verified.'
}

function Get-OfficialCandidate {
    Write-DebugLog "Reading official download API: $ApiUrl"
    $response = Invoke-RestMethod -Uri $ApiUrl -Method Get -MaximumRedirection 5 -TimeoutSec 30
    if (-not $response.data) { throw 'Official API returned no data.' }
    $url = [string]$response.data.url
    $versionName = [string]$response.data.version_name
    if ([string]::IsNullOrWhiteSpace($url) -or [string]::IsNullOrWhiteSpace($versionName)) {
        throw 'Official API response is missing url or version_name.'
    }
    $uri = [Uri]$url
    if ($uri.Scheme -ne 'https' -or $uri.Host -ne $OfficialHost -or -not $uri.AbsolutePath.EndsWith('.exe', [StringComparison]::OrdinalIgnoreCase)) {
        throw "API returned an unexpected installer URL: $url"
    }
    $version = ConvertTo-Version $versionName
    [pscustomobject]@{ Version = $version; Url = $url; FileName = [IO.Path]::GetFileName($uri.AbsolutePath); ReleaseDate = [string]$response.data.release_date }
}

function Test-Installer([string]$Path, [version]$ExpectedVersion) {
    if (-not (Test-Path -LiteralPath $Path -PathType Leaf)) { throw "Installer not found: $Path" }
    $item = Get-Item -LiteralPath $Path
    if ($item.Length -lt 1MB) { throw "Installer is unexpectedly small: $($item.Length) bytes" }
    $signature = Get-AuthenticodeSignature -FilePath $Path
    if ($signature.Status -ne 'Valid') { throw "Authenticode validation failed: $($signature.Status)" }
    Write-Log "Signer: $($signature.SignerCertificate.Subject)"
    $fileVersion = [Diagnostics.FileVersionInfo]::GetVersionInfo($Path).FileVersion
    if (-not [string]::IsNullOrWhiteSpace($fileVersion)) {
        $actual = ConvertTo-Version $fileVersion
        if ($actual -lt $ExpectedVersion) { throw "Installer version $actual is older than expected $ExpectedVersion" }
    }
    $hash = (Get-FileHash -LiteralPath $Path -Algorithm SHA256).Hash.ToLowerInvariant()
    Write-Log "Installer verified: $($item.Length) bytes, SHA-256 $hash"
    return $true
}

function Save-Installer($Candidate) {
    New-Item -ItemType Directory -Path $DownloadDirectory -Force | Out-Null
    $destination = Join-Path $DownloadDirectory $Candidate.FileName
    $part = "$destination.part"
    if (Test-Path -LiteralPath $part) { Remove-Item -LiteralPath $part -Force }
    Write-Log "Downloading official installer: $($Candidate.Url)"
    Invoke-WebRequest -Uri $Candidate.Url -OutFile $part -UseBasicParsing -MaximumRedirection 5 -TimeoutSec 300
    Move-Item -LiteralPath $part -Destination $destination -Force
    Test-Installer $destination $Candidate.Version | Out-Null
    return $destination
}

function Show-Menu([version]$InstalledVersion, [version]$OfficialVersion) {
    Write-Host ''
    Write-Host 'Doubao IME Manager'
    Write-Host '----- Information -----' -ForegroundColor Yellow
    Write-Host ('Installed: {0}' -f $InstalledVersion)
    Write-Host ('Official:  {0}' -f $OfficialVersion)
    Write-Host ''
    Write-Host '----- Install / Deployment -----' -ForegroundColor Yellow
    Write-Host '1. Download and verify only'
    Write-Host '2. Launch installer (manual click; show installer UI)'
    Write-Host '3. UI automatic install (/silent; reboot prompt remains)'
    Write-Host '4. Super-silent install (/verysilent; may reboot automatically; DANGEROUS)'
    Write-Host ''
    Write-Host '----- Uninstall -----' -ForegroundColor Yellow
    Write-Host '5. Normal uninstall (show uninstaller UI)'
    Write-Host '6. Silent uninstall (may close apps; DANGEROUS)'
    Write-Host '0. Exit'
    do { $choice = Read-Host 'Select [0-6]' } while ($choice -notmatch '^[0-6]$')
    return [int]$choice
}

function Start-OfficialInstall([string]$Installer, [string]$Arguments) {
    if ([string]::IsNullOrWhiteSpace($Arguments)) {
        Write-Log 'Starting official installer with its normal visible UI.'
    } else {
        Write-Log "Starting official installer with arguments: $Arguments"
    }
    $process = Start-Process -FilePath $Installer -ArgumentList $Arguments -Wait -PassThru
    if ($process.ExitCode -ne 0) { throw "Installer exited with code $($process.ExitCode)" }
}

try {
    Write-DebugLog '=== Doubao IME Manager ==='
    $installed = Get-InstalledVersion
    $candidate = Get-OfficialCandidate
    Write-DebugLog "Installed version: $($installed.Version)"
    Write-DebugLog "Official version:  $($candidate.Version)"
    if ($Interactive) { $InstallerArguments = '' }
    if ($CheckOnly) { Write-Log 'CheckOnly specified; no download or install performed.'; exit 0 }

    $menuChoice = $null
    if (-not $NoInstall -and [string]::IsNullOrWhiteSpace($InstallerArguments) -and -not $Interactive -and -not $Force) {
        $menuChoice = Show-Menu $installed.Version $candidate.Version
        if ($menuChoice -eq 0) { Write-Log 'Exit.'; exit 0 }
        if ($menuChoice -eq 1) { $NoInstall = $true }
        if ($menuChoice -eq 2) { $InstallerArguments = '' }
        if ($menuChoice -eq 3) { $InstallerArguments = '/silent' }
        if ($menuChoice -eq 4) { $InstallerArguments = '/verysilent' }
    }

    if ($menuChoice -in @(5, 6)) {
        $uninstall = Get-UninstallInfo
        if (-not $uninstall) { throw 'Doubao IME uninstall entry was not found.' }
        if ($menuChoice -eq 5) {
            $confirm = Read-Host 'Type UNINSTALL to confirm normal uninstall'
            if ($confirm -cne 'UNINSTALL') { Write-Log 'Uninstall cancelled.'; exit 0 }
            Invoke-Uninstall $uninstall $false
        } else {
            Write-Host '' -ForegroundColor Red
            Write-Host 'WARNING: Silent uninstall may close Doubao IME and other related processes.' -ForegroundColor Red
            Write-Host 'It may also trigger a restart depending on the official uninstaller.' -ForegroundColor Red
            $confirm1 = Read-Host 'Type EXACTLY ALLOW-UNINSTALL to continue'
            if ($confirm1 -cne 'ALLOW-UNINSTALL') { Write-Log 'Silent uninstall cancelled.'; exit 0 }
            $confirm2 = Read-Host 'Type EXACTLY ALLOW-UNINSTALL again'
            if ($confirm2 -cne 'ALLOW-UNINSTALL') { Write-Log 'Silent uninstall cancelled.'; exit 0 }
            Invoke-Uninstall $uninstall $true
        }
        Read-Host 'Press Enter to exit' | Out-Null
        exit 0
    }

    if (-not $Force -and $candidate.Version -le $installed.Version -and $null -eq $menuChoice) {
        Write-Log 'Already up to date.'
        exit 0
    }

    $installer = Save-Installer $candidate
    if ($NoInstall) { Write-Log "Download complete: $installer"; Read-Host 'Press Enter to exit' | Out-Null; exit 0 }

    if ($InstallerArguments -match '(?i)(^|\s)(/verysilent|/veryquiet)(\s|$)') {
        Write-Host '' -ForegroundColor Red
        Write-Host 'WARNING: Super-silent mode may restart the computer automatically.' -ForegroundColor Red
        Write-Host 'Save all work first. Unsaved data may be lost.' -ForegroundColor Red
        Write-Host 'This mode hides the installer UI and cannot be interrupted safely.' -ForegroundColor Red
        $confirm = Read-Host 'Type EXACTLY ALLOW-REBOOT to continue'
        if ($confirm -cne 'ALLOW-REBOOT') {
            Write-Log 'Super-silent installation cancelled.'
            if ($null -ne $menuChoice) { Read-Host 'Press Enter to exit' | Out-Null }
            exit 0
        }
        Write-Log 'Dangerous super-silent installation explicitly confirmed.'
    }

    Start-OfficialInstall $installer $InstallerArguments
    $after = Get-InstalledVersion
    if ($after.Version -lt $candidate.Version) {
        Write-Log "Installer completed, but detected installed version is still $($after.Version)."
        exit 2
    }
    Write-Log "Update completed: $($after.Version)"
    if ($null -ne $menuChoice) { Read-Host 'Press Enter to exit' | Out-Null }
    exit 0
} catch {
    Write-Error $_.Exception.Message
    exit 1
}
