# WSL Integration Reference

Use this reference when configuring WSL-specific behavior: launching Linux commands from Windows PowerShell/CMD, checking whether a named WSL distribution already exists, setting WSL default users, selecting WSLg vs an external X Server, or troubleshooting GUI display routing.

## Safe Windows-to-WSL Command Execution

A command may be parsed by multiple layers before Linux receives it:

1. Agent/tool command serializer.
2. Windows PowerShell or CMD.
3. `wsl.exe` argument forwarding.
4. The Linux command or shell, often `bash -c` / `bash -lc`.

Each layer can reinterpret quotes, backticks, `%` variables, `$` variables, pipes, redirection, `&&`, parentheses, wildcard characters, and non-ASCII text. Multi-line locale setup and CJK filename tests are especially easy to damage.

Use direct calls only for simple commands:

```powershell
wsl --list --verbose
wsl --distribution <DistributionName> -- whoami
wsl --distribution <DistributionName> -- cat /etc/os-release
```

For complex setup, write a UTF-8 Linux script and execute it inside WSL:

```powershell
wsl --distribution <DistributionName> --user root -- bash /mnt/c/path/to/setup.sh
```

Example Linux script content:

```bash
#!/usr/bin/env bash
set -euo pipefail
apt update -y
apt install -y locales language-pack-en language-pack-zh-hans language-pack-zh-hant fonts-noto-cjk fonts-wqy-zenhei fonts-wqy-microhei fontconfig
sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
locale-gen en_US.UTF-8
update-locale LANG=en_US.UTF-8 LANGUAGE  # bare LANGUAGE removes a stale LANGUAGE override if present
```

If the script is created on Windows, save it as UTF-8 and prefer LF line endings. If CRLF causes issues, fix it inside WSL:

```bash
sed -i 's/\r$//' /mnt/c/path/to/setup.sh
```

Avoid embedding Chinese text, here-documents, `$()`, JSON, sed expressions, shell functions, or long quoted shell pipelines directly in `wsl -- bash -lc "..."` unless carefully tested.

## WSL Distribution Existence Preflight

Run this before creating, importing, or installing a WSL distribution with a requested name. Never loop on same-name create/import failures. If the name already exists, reuse or repair the existing distro instead.

Failure modes this prevents:

- `wsl.exe` output contains NUL characters or mojibake, so a name is visually hidden.
- The Agent runs in a sandbox/service account and sees a different WSL registration view from the user's interactive PowerShell.
- `wsl --install`, `wsl --import`, or a GUI installer says the name already exists, but the Agent keeps retrying creation.
- The distro exists in the per-user WSL registry under `HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss` even when a plain list command was not parsed correctly.

Authoritative preflight from the user's Windows PowerShell:

```powershell
$Target = 'Agent_Dev_Env1'
[Console]::OutputEncoding = [Text.UTF8Encoding]::new($false)
$OutputEncoding = [Console]::OutputEncoding

'== Windows identity =='
whoami
'== WSL status/list =='
wsl.exe --status
wsl.exe --list --all --verbose

$WslNames = @(wsl.exe --list --quiet 2>$null) |
  ForEach-Object { ($_ -replace "`0", '').Trim() } |
  Where-Object { $_ }

$RegDistros = Get-ChildItem 'HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss' -ErrorAction SilentlyContinue |
  ForEach-Object {
    $p = Get-ItemProperty $_.PSPath
    [PSCustomObject]@{
      Guid = $_.PSChildName
      DistributionName = $p.DistributionName
      BasePath = $p.BasePath
      State = $p.State
      Version = $p.Version
    }
  }

'== normalized names from wsl.exe =='
$WslNames
'== WSL registry records =='
$RegDistros | Sort-Object DistributionName | Format-Table -AutoSize

$Exists = ($WslNames -contains $Target) -or ($RegDistros.DistributionName -contains $Target)
if ($Exists) {
  "FOUND: $Target already exists. Stop create/import; configure this distro instead."
  wsl.exe --distribution $Target -- whoami
  wsl.exe --distribution $Target -- cat /etc/os-release
} else {
  "NOT FOUND from this Windows user/session: $Target. Only create/import after confirming this is the correct user context."
}
```

When table output is unreadable, prefer JSON:

```powershell
[PSCustomObject]@{
  Target = $Target
  WslNames = $WslNames
  RegistryDistros = $RegDistros
} | ConvertTo-Json -Depth 5
```

If the Agent's sandboxed PowerShell disagrees with the user's terminal, trust the user's interactive Windows account for that user's WSL distros. Ask for external/elevated execution only when required by the environment, and report `whoami` for both views. Elevation is not a substitute for checking the correct Windows user: WSL registrations are per-user.

If a previous create/import attempt already failed with "already exists", do not retry the same create command. Run this preflight, then either:

```powershell
# Reuse/configure the existing distro
wsl.exe --distribution Agent_Dev_Env1 -- whoami

# Restart after config changes
wsl.exe --terminate Agent_Dev_Env1
```

Only unregister/delete a distro after explicit user confirmation and backup, because it destroys the distro's Linux filesystem.

## WSL GUI Display: WSLg vs External X Server

Prefer WSLg when:

- The host is Windows 11 or a current Windows 10/11 build with WSL 2 GUI support.
- The user wants local Linux GUI apps integrated with Windows.
- The app benefits from WSLg's Wayland/X11 integration, clipboard support, audio path, and vGPU path.
- External X Server windows open but drag, resize, focus, DPI, or clipboard behavior is poor.

Use an external X Server when:

- WSLg is unavailable, disabled, or unsupported.
- The distro is WSL 1 or the host is an older Windows build.
- The user intentionally relies on MobaXterm/VcXsrv/Xming features.
- The workflow is remote X11 forwarding rather than local WSL GUI rendering.

Detect current state inside WSL:

```bash
echo "DISPLAY=$DISPLAY"
echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
echo "PULSE_SERVER=$PULSE_SERVER"
[ -d /mnt/wslg ] && cat /mnt/wslg/versions.txt || true
ls -la /tmp/.X11-unix 2>/dev/null || true
ls -la /mnt/wslg/.X11-unix 2>/dev/null || true
```

From Windows PowerShell/CMD:

```powershell
wsl --version
wsl -l -v
```

WSLg requires WSL 2 for GUI applications. If WSL is older, update and restart:

```powershell
wsl --update
wsl --shutdown
```

## Switch Current Shell to WSLg

```bash
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
export PULSE_SERVER=unix:/mnt/wslg/PulseServer
```

Only add persistent WSLg preference when profile scripts or external-X tooling repeatedly overwrite WSLg variables:

```bash
cat >> ~/.bashrc <<'EOF'
# Prefer WSLg for local WSL GUI apps when WSLg is available.
if [ -d /mnt/wslg ]; then
  export DISPLAY=:0
  export WAYLAND_DISPLAY=wayland-0
  export PULSE_SERVER=unix:/mnt/wslg/PulseServer
fi
EOF
```

## Switch Current Shell to External X Server

Start the Windows X Server first and allow Windows Firewall access. Then run in WSL:

```bash
export DISPLAY="$(ip route | awk '/^default/ {print $3; exit}'):0"
unset WAYLAND_DISPLAY
```

If the X Server uses a fixed host or display number, use it explicitly. In some WSL 1 or legacy external-X workflows, `localhost:0` may be correct instead of the WSL 2 default-gateway address:

```bash
export DISPLAY=<windows-host-ip>:0
# or, when appropriate for the user's X Server/networking mode:
export DISPLAY=localhost:0
```

## Optional Shell Functions

Add these functions only for users who frequently switch display paths:

```bash
use-wslg() {
  export DISPLAY=:0
  export WAYLAND_DISPLAY=wayland-0
  export PULSE_SERVER=unix:/mnt/wslg/PulseServer
}

use-xserver() {
  export DISPLAY="${1:-$(ip route | awk '/^default/ {print $3; exit}'):0}"
  unset WAYLAND_DISPLAY
}
```

## Host-Side WSLg Enablement

WSLg is controlled globally in `%UserProfile%\.wslconfig` for WSL 2 distributions. If disabled, re-enable it:

```ini
[wsl2]
guiApplications=true
```

Apply the change:

```powershell
wsl --shutdown
```

Wait until WSL has fully stopped before relaunching the distro.

## WSL User Defaults

For a one-off WSL launch as an existing user from Windows PowerShell/CMD:

```powershell
wsl --distribution <DistributionName> --user agent
```

For Store-installed distributions with a launcher, set the default user:

```powershell
<DistributionName> config --default-user agent
```

For imported distributions without a launcher, use `/etc/wsl.conf` only after confirming the distro is imported and the target user exists:

```ini
[user]
default=agent
```

Then restart and verify:

```powershell
wsl --terminate <DistributionName>
wsl --distribution <DistributionName> -- whoami
```

## Troubleshooting

- If PowerShell reports parser errors before WSL starts, the failure happened in the Windows shell layer.
- If WSL starts but Bash reports syntax errors, simplify the Windows command and move Linux logic into a script file.
- If Chinese text appears corrupted only in captured logs, re-test directly in the user's terminal before changing locale again.
- If the Agent cannot see the same WSL distros as the user, compare `wsl -l -v`, normalized `wsl --list --quiet`, and the `HKCU:\Software\Microsoft\Windows\CurrentVersion\Lxss` registry records from the Agent and from the user's own PowerShell session.
- If create/import says a distro name already exists, stop retrying and run the distribution existence preflight. A same-name error is evidence that the name is already registered somewhere in the current or intended Windows-user view.
- If `DISPLAY` is not `:0` while WSLg is intended, look for shell startup files that override it: `~/.bashrc`, `~/.profile`, `/etc/profile`, `/etc/profile.d/*`.
- If a MobaXterm/VcXsrv/Xming window opens but cannot be dragged or integrates poorly with Windows, switch that shell back to WSLg.
- If `wsl --version` is missing, update WSL from Microsoft Store or Windows Update before relying on WSLg behavior.
- If GUI apps still cannot open on WSLg, collect `cat /mnt/wslg/versions.txt`, `echo $DISPLAY`, X11 socket listings, and `/mnt/wslg/weston.log` for diagnosis.
- If `/tmp/.X11-unix` was replaced by custom `/tmp` handling, inspect it first and back it up before recreating a WSLg symlink to `/mnt/wslg/.X11-unix`; do not delete it blindly.
