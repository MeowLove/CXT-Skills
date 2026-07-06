# Distro Command Reference

Copy only the block matching the detected distro. Ask for approval before running sudo/root commands.

## Detect environment

```bash
cat /etc/os-release
locale
locale -a | grep -i '^en_US\.utf8$\|^en_US\.UTF-8$' || true
date
timedatectl status 2>/dev/null || true
```

## Ubuntu / WSL Ubuntu

```bash
sudo apt update -y
sudo apt install -y locales language-pack-en language-pack-zh-hans language-pack-zh-hant fonts-noto-cjk fonts-wqy-zenhei fonts-wqy-microhei fontconfig
sudo sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LANGUAGE  # bare LANGUAGE removes a stale LANGUAGE override if present
```

## Debian / minimal Ubuntu fallback

```bash
sudo apt update -y
sudo apt install -y locales fonts-noto-cjk fonts-wqy-zenhei fonts-wqy-microhei fontconfig
sudo sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LANGUAGE  # bare LANGUAGE removes a stale LANGUAGE override if present
```

## Fedora / RHEL-family

```bash
sudo dnf install -y glibc-langpack-en glibc-langpack-zh 'google-noto-*-cjk-fonts' fontconfig
if dnf repoquery wqy-zenhei-fonts wqy-microhei-fonts >/dev/null 2>&1; then
  sudo dnf install -y wqy-zenhei-fonts wqy-microhei-fonts
else
  echo 'WenQuanYi font packages are not available in the enabled repositories; keep Noto CJK or enable an approved repository first.'
fi
sudo localectl set-locale LANG=en_US.UTF-8
```

Check available broad CJK font packages if the wildcard does not resolve:

```bash
dnf repoquery 'google-noto-*-cjk-fonts' || true
sudo dnf install -y google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts fontconfig
# Fedora alternative when available:
sudo dnf install -y default-fonts-cjk
```

Fallback when localectl is unavailable:

```bash
printf 'LANG=en_US.UTF-8\n' | sudo tee /etc/locale.conf
```

## Non-core font package name hints for other distros

This skill's supported execution paths are Debian/Ubuntu-family and Fedora/RHEL-family. Do not expand locale, GUI, user, timezone, or Agent-install workflows to other distros by default. The following names are only package-name hints for user-requested/manual adaptation; verify the target release before installing:

```bash
# Arch Linux
sudo pacman -S --needed noto-fonts-cjk wqy-zenhei wqy-microhei

# openSUSE / SUSE-family
sudo zypper install google-noto-sans-cjk-fonts wqy-zenhei-fonts wqy-microhei-fonts
```

## Optional additional languages while keeping LANG=en_US.UTF-8

```bash
# Ubuntu examples
sudo apt install -y language-pack-fr language-pack-ru fonts-noto-core

# Debian examples
sudo apt install -y locales fonts-noto-core

# Fedora / RHEL-family examples
sudo dnf install -y glibc-langpack-fr glibc-langpack-ru google-noto-sans-fonts
```

## Timezone

```bash
sudo timedatectl set-timezone UTC
# or
sudo timedatectl set-timezone Asia/Singapore
```

## Windows/Linux dual-boot RTC mode

```bash
# Match Windows local-time RTC behavior on physical dual-boot machines:
sudo timedatectl set-local-rtc 1

# If current RTC should immediately drive system clock:
sudo timedatectl set-local-rtc 1 --adjust-system-clock

# Revert to normal UTC RTC mode:
sudo timedatectl set-local-rtc 0
```

## WSL-specific commands

Use `references/wsl-integration.md` for Windows-to-WSL execution, WSL default-user settings, WSLg display routing, external X Server switching, and WSL GUI troubleshooting.

## Optional GUI/AppImage runtime

Use `references/gui-appimage-runtime.md` for the complete GUI/AppImage dependency set before installing more than FUSE compatibility. Install only when the user needs GUI/AppImage/Electron support on a minimal Linux/WSL environment.

```bash
# Debian/Ubuntu: FUSE compatibility for AppImage. Ubuntu 24.04+ may use libfuse2t64. Do not install the legacy fuse package on Ubuntu 22.04+ just for AppImage.
if apt-cache show libfuse2t64 >/dev/null 2>&1; then sudo apt install -y libfuse2t64; else sudo apt install -y libfuse2; fi

# Fedora/RHEL-family: FUSE compatibility for AppImage.
sudo dnf install -y fuse-libs
```

## Agent user

```bash
sudo useradd -m -s /bin/bash agent
sudo passwd agent
sudo usermod -aG sudo agent
su - agent
sudo whoami
```

## WSL launch/default user from Windows PowerShell or CMD

```powershell
wsl --distribution <DistributionName> --user agent
<DistributionName> config --default-user agent
wsl -l -v
```

For imported distributions, use `/etc/wsl.conf` inside the distro:

```ini
[user]
default=agent
```

Then restart and verify:

```powershell
wsl --terminate <DistributionName>
wsl --distribution <DistributionName> -- whoami
```

## Verify

```bash
locale
date
printf '中文文件名测试\n' > 中文文件名测试.txt
ls -l 中文文件名测试.txt
cat 中文文件名测试.txt
rm 中文文件名测试.txt
fc-match ':lang=zh-cn' 2>/dev/null || fc-match 'Noto Sans CJK' 2>/dev/null || true
echo "DISPLAY=$DISPLAY WAYLAND_DISPLAY=$WAYLAND_DISPLAY PULSE_SERVER=$PULSE_SERVER"
```
