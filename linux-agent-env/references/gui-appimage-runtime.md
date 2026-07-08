# GUI and AppImage Runtime Reference

Use this reference only when the user needs GUI applications, AppImage tools, Electron/Chromium-based apps, or Tauri/WebKitGTK apps on a minimal Linux/WSL environment.

## Policy

- Prefer WSLg for current Windows 11/WSL 2 GUI apps; use `references/wsl-integration.md` for display routing.
- Do not install a full desktop environment by default. Install runtime libraries and test tools only. For building Tauri apps from source, use `references/agent-gui-management.md` because build prerequisites are larger than runtime dependencies.
- Install packages only after user approval because this changes system packages.
- Verify architecture before downloading AppImage assets:

```bash
uname -m
```

Match `x86_64` assets to x86_64 Linux, and `aarch64`/`arm64` assets to ARM64 Linux. Do not run an `arm64` AppImage on an `x86_64` WSL distro.

## AppImage FUSE Support

Many AppImages need FUSE 2 compatibility. Install the distro compatibility library first; on Ubuntu 22.04+ do not install the legacy `fuse` package just to run AppImages because distro docs warn that it can conflict with the default FUSE stack. Use extraction only when FUSE cannot be used.

### Debian / Ubuntu

```bash
sudo apt update -y
if apt-cache show libfuse2t64 >/dev/null 2>&1; then
  sudo apt install -y libfuse2t64
else
  sudo apt install -y libfuse2
fi
```

### Fedora / RHEL-family

```bash
sudo dnf install -y fuse-libs
```

### FUSE fallback: extract AppImage

```bash
chmod +x ./SomeApp.AppImage
./SomeApp.AppImage --appimage-extract
./squashfs-root/AppRun
```

Use this fallback for locked-down WSL/container environments or when FUSE kernel support is unavailable.

## Minimal GUI Runtime Libraries

Install these when GUI apps fail with missing GTK, NSS, audio, GBM/DRM, X11, WebKitGTK, or accessibility libraries. Package availability can vary by release; if a package is missing, use `apt-cache search`, `apt-file search`, `dnf repoquery`, or `dnf provides` for the reported `.so` file.

### Debian / Ubuntu

```bash
sudo apt update -y
sudo apt install -y \
  ca-certificates curl file xz-utils desktop-file-utils dbus-x11 xdg-utils \
  libgtk-3-0 libnss3 libxss1 libxtst6 libx11-xcb1 libxcb-dri3-0 \
  libxkbcommon0 libxcomposite1 libxdamage1 libxrandr2 libgbm1 libdrm2 \
  libxshmfence1 libatk-bridge2.0-0 libatspi2.0-0

if apt-cache show libasound2t64 >/dev/null 2>&1; then
  sudo apt install -y libasound2t64
else
  sudo apt install -y libasound2
fi

# Tauri/WebKitGTK runtime for desktop apps such as Polaris/TOKENICODE when not bundled by the package.
if apt-cache show libwebkit2gtk-4.1-0 >/dev/null 2>&1; then
  sudo apt install -y libwebkit2gtk-4.1-0
elif apt-cache show libwebkit2gtk-4.0-37 >/dev/null 2>&1; then
  sudo apt install -y libwebkit2gtk-4.0-37
fi
```

For a simple X11 smoke test:

```bash
sudo apt install -y x11-apps
xclock &
```

### Fedora / RHEL-family

```bash
sudo dnf install -y \
  ca-certificates curl file xz desktop-file-utils dbus-x11 xdg-utils \
  gtk3 nss libXScrnSaver libXtst libxkbcommon libXcomposite libXdamage \
  libXrandr mesa-libgbm libdrm libxshmfence at-spi2-atk alsa-lib fuse-libs
```

Install WebKitGTK runtime only when a Tauri app reports missing WebKitGTK:

```bash
if dnf list --available webkit2gtk4.1 >/dev/null 2>&1 || dnf list --installed webkit2gtk4.1 >/dev/null 2>&1; then
  sudo dnf install -y webkit2gtk4.1
elif dnf list --available webkit2gtk4.0 >/dev/null 2>&1 || dnf list --installed webkit2gtk4.0 >/dev/null 2>&1; then
  sudo dnf install -y webkit2gtk4.0
fi
```

If a package name is missing on RHEL-family systems, query the missing library rather than guessing:

```bash
dnf provides '*/libgtk-3.so.0' '*/libnss3.so' '*/libgbm.so.1' '*/libasound.so.2' '*/libwebkit2gtk-4.1.so*'
```

## Running a Downloaded AppImage Safely

```bash
file ./SomeApp.AppImage
chmod +x ./SomeApp.AppImage
./SomeApp.AppImage --version 2>/dev/null || ./SomeApp.AppImage
```

If the app is CC-Switch or another Agent GUI utility, download only from the tool's official GitHub releases or official website, select the asset that matches `uname -m`, and keep it under the normal user's home directory, for example `~/Applications`.
