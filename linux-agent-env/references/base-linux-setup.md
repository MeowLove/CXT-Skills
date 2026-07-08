# Base Linux/WSL Setup: Locale, Fonts, Time, and User

Use this reference for the base layer: distro detection, CJK fonts, English UTF-8 locale, optional supplemental languages, timezone/RTC, normal `agent` user, and base verification.

## Policy

- Keep persistent default locale as `LANG=en_US.UTF-8` for predictable English messages and broad tooling compatibility.
- Do not persist `LC_ALL` unless the user explicitly asks. `LC_ALL` overrides all locale categories and can surprise programs.
- Install CJK fonts/language data so Chinese/Japanese/Korean filenames and GUI text render correctly even though the process locale remains English UTF-8.
- For one-click/default setup with no user password specified, create `agent` with password `cxthhhhh.com`. Do not create empty-password sudo or `NOPASSWD` sudo unless explicitly requested.

## Detect

```bash
cat /etc/os-release
id
whoami
echo "HOME=$HOME"
locale || true
locale -a | grep -E 'en_US\.utf8|en_US\.UTF-8|C\.UTF-8|zh_CN' || true
date
```

## Install Locale Data and CJK Fonts

### Ubuntu / WSL Ubuntu

```bash
sudo apt update -y
sudo apt install -y \
  locales \
  language-pack-en \
  language-pack-zh-hans \
  language-pack-zh-hant \
  fonts-noto-cjk \
  fonts-wqy-zenhei \
  fonts-wqy-microhei \
  fontconfig
sudo fc-cache -fv
```

### Debian / Minimal Ubuntu Fallback

Debian commonly uses `locales` plus font packages. Do not assume Ubuntu `language-pack-*` packages exist on Debian.

```bash
sudo apt update -y
sudo apt install -y \
  locales \
  fonts-noto-cjk \
  fonts-wqy-zenhei \
  fonts-wqy-microhei \
  fontconfig
sudo fc-cache -fv
```

### Fedora / RHEL-family

```bash
sudo dnf update -y
sudo dnf install -y \
  glibc-langpack-en \
  glibc-langpack-zh \
  'google-noto-*-cjk-fonts' \
  fontconfig
sudo fc-cache -fv
```

If the wildcard Noto CJK package expression is unavailable in the current repository set, search and install the available exact package names:

```bash
dnf search noto | grep -i cjk || true
sudo dnf install -y google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts || true
```

WenQuanYi packages on Fedora/RHEL-family are repository-dependent. Install only when available:

```bash
dnf search wqy wenquanyi || true
sudo dnf install -y wqy-zenhei-fonts wqy-microhei-fonts || true
```

## Generate and Persist English UTF-8 Locale

### Debian / Ubuntu

```bash
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8
```

If `locale-gen` is missing, install `locales`. If `update-locale` is missing, write `/etc/default/locale` carefully:

```bash
printf 'LANG=en_US.UTF-8\n' | sudo tee /etc/default/locale
```

### Fedora / RHEL-family

```bash
sudo localectl set-locale LANG=en_US.UTF-8
```

Fallback when `localectl` is unavailable:

```bash
printf 'LANG=en_US.UTF-8\n' | sudo tee /etc/locale.conf
```

Reload the shell or start a new login session, then verify:

```bash
locale
locale -a | grep -E 'en_US\.utf8|en_US\.UTF-8'
```

Expected: `LANG=en_US.UTF-8` and no persistent `LC_ALL` unless explicitly requested.

## Optional Supplemental Language Packs

Keep `LANG=en_US.UTF-8`; add extra language data/fonts only when applications need them.

Examples:

```bash
# Ubuntu examples
sudo apt install -y language-pack-ja language-pack-ko language-pack-fr language-pack-ru fonts-noto-cjk fonts-noto-color-emoji

# Fedora/RHEL-family examples
sudo dnf install -y glibc-langpack-ja glibc-langpack-ko glibc-langpack-fr glibc-langpack-ru google-noto-emoji-fonts
```

For languages not listed here, search the distro package index and install the matching `language-pack-*` or `glibc-langpack-*` package plus fonts needed by the target script.

## Timezone and RTC

Do not change timezone unless the user asks or the task requires it.

Recommended server/automation timezone:

```bash
sudo timedatectl set-timezone UTC
```

Stable UTC+8 civil timezone without using a China locale:

```bash
sudo timedatectl set-timezone Asia/Singapore
```

Verify:

```bash
timedatectl 2>/dev/null || true
date
```

### Windows/Linux Dual-Boot RTC

Use this only for physical dual-boot machines where Windows and Linux disagree about hardware clock time. For normal WSL, containers, and cloud VMs, do not set this by default.

```bash
sudo timedatectl set-local-rtc 1
```

Warn the user that UTC hardware clock is usually preferred for Linux-only/server systems.

## Create Least-Privilege Agent User

Run as root or with sudo:

```bash
id agent 2>/dev/null || sudo useradd -m -s /bin/bash agent
printf 'agent:cxthhhhh.com\n' | sudo chpasswd
sudo usermod -aG sudo agent
```

Debian/Ubuntu may need `sudo` installed first on minimal images:

```bash
command -v sudo >/dev/null 2>&1 || apt update && apt install -y sudo
```

Switch and test:

```bash
su - agent
whoami
sudo whoami
```

Expected output for `sudo whoami` is `root` after entering the user's password. Do not configure passwordless sudo unless the user explicitly requests it.

## Base Verification

```bash
locale
locale -a | grep -E 'en_US\.utf8|en_US\.UTF-8'
printf '中文文件名测试\n' > 中文文件名测试.txt
ls -l 中文文件名测试.txt
cat 中文文件名测试.txt
fc-match 'Noto Sans CJK SC' || true
fc-match 'WenQuanYi Zen Hei' || true
fc-match 'WenQuanYi Micro Hei' || true
date
```

GUI font verification, when GUI is available:

```bash
fc-list | grep -Ei 'Noto.*CJK|WenQuanYi|wqy' | head -50
```

## Common Issues

- Filenames show `????`: verify terminal encoding, `LANG`, `locale -a`, and the capture layer. Some automation logs corrupt text even when WSL/Linux is correct.
- GUI text shows boxes/tofu: reinstall CJK fonts, run `fc-cache -fv`, and restart the GUI app/session.
- `locale-gen` missing: install `locales`.
- `update-locale` missing: use distro-specific locale config file or `localectl`.
- Timezone changes revert in WSL/containers: the host/runtime may override time settings; configure the host/runtime layer instead.
- `sudo` works without a password because automation created an empty password or `NOPASSWD`: treat as a setup bug unless explicitly requested; set a real password.
