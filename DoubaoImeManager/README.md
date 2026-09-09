# Doubao IME Manager

PowerShell-based manager for the official Doubao IME Windows installer. It can discover the latest official package, download and verify it, install it, and uninstall Doubao IME.

## Files

- `DoubaoImeManager.bat`: double-click launcher for interactive use.
- `DoubaoImeManager.ps1`: main implementation and command-line entry point.

## Interactive Menu

Run `DoubaoImeManager.bat` and choose:

1. Download and verify only.
2. Launch the installer with its normal UI; click **Install** manually.
3. UI automatic installation using `/silent`; the official reboot prompt remains visible.
4. Super-silent installation using `/verysilent`; may restart Windows automatically and can lose unsaved work.
5. Normal uninstall using the official uninstaller UI.
6. Silent uninstall using the official quiet uninstall command; may close related processes.
0. Exit.

Options 4 and 6 require explicit confirmation. Save all work before using them.

## Command Line

```powershell
# Interactive menu
DoubaoImeManager.bat

# Check the official version without downloading or installing
DoubaoImeManager.bat -CheckOnly

# Download and verify only
DoubaoImeManager.bat -NoInstall

# Show diagnostic API and version logs
DoubaoImeManager.bat -DebugMode

# Use the official semi-silent installation mode directly
DoubaoImeManager.bat -InstallerArguments "/silent"
```

The manager rejects `/veryquiet` and `/verysilent` unless the interactive safety confirmation is completed.

## Verification and Safety

- Downloads use a temporary `.part` file before being moved into place.
- The download URL must be HTTPS and use the official Doubao CDN host.
- The installer must have a valid Authenticode signature.
- The installer SHA-256 hash is calculated and logged after verification.
- The installer and uninstaller are launched only after their paths are resolved.
- The uninstaller command is read from the Windows uninstall registry entry instead of being hard-coded.

## Requirements

- Windows PowerShell 5.1 or PowerShell 7.
- Internet access to `shurufa.doubao.com` and `lf-wave.doubaocdn.com`.
- Administrator rights may be required by the official installer or uninstaller.

The official version endpoint is:

`https://shurufa.doubao.com/api/v1/app/download_url?platform=windows`
