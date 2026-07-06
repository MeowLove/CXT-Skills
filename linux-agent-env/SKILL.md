---
name: linux-agent-env
description: Prepare Linux agent environments, including WSL targets, with reliable Chinese/CJK terminal filenames, GUI font rendering with Noto and supplemental WenQuanYi fonts, English UTF-8 default locale, WSLg/X Server display routing, minimal GUI/AppImage runtime libraries, safe Windows-to-WSL command execution, timezone/RTC behavior, optional supplemental languages, optional Agent CLI installation guidance, WSL default-user setup, and least-privilege non-root agent users. Use for Debian/Ubuntu, WSL Ubuntu/Debian, Fedora/RHEL-family package setup, CJK fonts, LANG setup, WSL GUI rendering troubleshooting, AppImage/Electron GUI dependency fixes, Claude Code/OpenAI Codex/OpenCode/Hermes/OpenClaw/CC-Switch installation planning, PowerShell-to-WSL quoting pitfalls, and authorized system administration requiring explicit approval for root/sudo changes.
---

# Linux Agent Environment Setup

## Purpose

Prepare Linux systems, including WSL distributions, for Agent use: make Chinese/Japanese/Korean text display correctly in terminals and GUI apps, keep the default process locale as `en_US.UTF-8` for predictable English messages and broad tooling compatibility, prefer least-privilege non-root operation, choose the correct WSL GUI display path, and optionally add minimal GUI/AppImage runtime support or requested Agent CLI tooling. For WSL GUI apps, prefer the built-in WSLg path on modern Windows unless the user intentionally needs an external X Server.

Source attribution: CXT, MeowLove — `WWW.CXTHHHHH.COM`.

Support scope: primary copy/paste command paths cover Debian/Ubuntu-family and Fedora/RHEL-family systems. WSL is treated as a supported Linux target with Windows host integration notes. Other distributions can use the same strategy, but package names and service behavior must be adapted from that distro's official documentation.

## Guardrails

- Ask for explicit user approval before changing packages, locale, timezone, RTC mode, users, passwords, sudo groups, WSL defaults, persistent shell startup files, or installing Agent CLIs.
- Treat this as authorized system administration for UTF-8, fonts, locale data, time settings, GUI display routing, and least-privilege Agent operation.
- Prefer `LANG=en_US.UTF-8` as the persistent default. Do not persist `LC_ALL` unless the user explicitly wants every locale category forced; `LC_ALL` overrides category-specific settings and can surprise applications.
- Prefer a normal user for day-to-day Agent work. Avoid running Agents as `root` unless the task requires root.
- In WSL or containers, expect host/runtime settings to override timezone, display variables, or environment on restart; verify after restart when persistence matters.

## Workflow

1. Detect distro and environment:
   - Run `cat /etc/os-release`, `locale`, `locale -a`, and `date`.
   - For WSL, also run `wsl -l -v` from Windows PowerShell/CMD when configuring defaults or diagnosing host-side behavior.
   - For WSL GUI apps, inspect `/mnt/wslg`, `DISPLAY`, `WAYLAND_DISPLAY`, `PULSE_SERVER`, and X11 sockets.
2. Install UTF-8 locale support, Noto CJK fonts, and when Chinese GUI compatibility matters, supplemental WenQuanYi fonts.
3. Generate/enable `en_US.UTF-8` and set persistent `LANG=en_US.UTF-8`.
4. Set timezone only when requested; prefer `UTC` for servers/automation, or `Asia/Singapore` for a stable UTC+8 civil timezone.
5. For Windows/Linux dual-boot machines, handle RTC mode only when the user reports cross-OS clock drift.
6. For WSL GUI apps, prefer WSLg on Windows 11 and recent WSL 2. Switch to an external X Server only for legacy or special workflows.
7. If the user needs GUI/AppImage/Electron apps on a minimal distro, install only the minimal runtime libraries needed; do not install a full desktop environment by default.
8. If the user asks for Agent CLI tools, install only the requested tool after verifying the current official upstream instructions.
9. Create a non-root Agent user if the current workflow is running as `root` or the user wants least privilege.
10. Verify with `locale`, `date`, a CJK filename test, `fc-match`, and GUI display checks when relevant.

Use `references/distro-commands.md` when exact copy/paste Linux command blocks are needed. Use `references/wsl-integration.md` for Windows-to-WSL execution, WSL default users, WSLg/X Server routing, and WSL GUI troubleshooting. Use `references/gui-appimage-runtime.md` for minimal GUI/AppImage/Electron runtime dependencies. Use `references/agent-cli-installation.md` for optional Agent CLI installation planning. Use `references/official-sources.md` only when auditing or updating the skill against upstream docs.


## Packaging Note

For GitHub distribution, the minimal portable package is the `linux-agent-env/` directory containing `SKILL.md` plus the `references/` directory. The `agents/` directory is Codex UI metadata and may be omitted when the target Agent only needs the skill instructions. Do not omit `references/` unless you first merge the needed reference content into `SKILL.md`.

## Windows-to-WSL Command Execution from Agents

Use `references/wsl-integration.md` when an Agent controls WSL from Windows PowerShell/CMD.

When commands pass through Agent tooling → PowerShell/CMD → `wsl.exe` → Linux shell, several parsers may reinterpret quotes, `$` variables, redirection, pipes, `&&`, backslashes, Unicode text, or here-documents. For short commands, direct `wsl --distribution <Name> -- <command>` is fine. For multi-line setup, locale text, Chinese filename tests, shell functions, or commands containing nested quotes, prefer writing a UTF-8 script file and executing that script inside WSL.

Recommended pattern:

```powershell
# 1. Write a UTF-8 Linux script from Windows tooling.
# 2. Convert the Windows path if needed.
# 3. Execute it with bash inside the target distro.
wsl --distribution <DistributionName> --user root -- bash /mnt/c/path/to/setup.sh
```

Inside the script, use normal Linux syntax without PowerShell escaping:

```bash
#!/usr/bin/env bash
set -euo pipefail
locale
printf '中文文件名测试\n' > 中文文件名测试.txt
ls -l 中文文件名测试.txt
rm 中文文件名测试.txt
```

Avoid packing complex multi-line Linux logic into `wsl -- bash -lc "..."` unless the quoting has been carefully tested. This reduces failures from Windows shell parsing and preserves UTF-8 content more reliably in automation logs.

## Install CJK Language and Font Support

### Font Strategy

- `fonts-noto-cjk` / `google-noto-*-cjk-fonts` remains the primary modern CJK choice because it covers Simplified Chinese, Traditional Chinese, Japanese, and Korean families.
- `fonts-wqy-zenhei` and `fonts-wqy-microhei` are useful supplemental Chinese fonts for legacy Linux UI/fontconfig compatibility and are safe to add when disk budget is not extremely tight.
- Install optional Song/Ming/Kai-style fonts only when documents or GUI apps need them. Debian/Ubuntu package names commonly include `fonts-arphic-uming` and `fonts-arphic-ukai`; Fedora-family package names commonly include `cjkuni-uming-fonts` and `cjkuni-ukai-fonts` when available. Query the package manager first instead of assuming every release carries them.
- Scope: the supported execution paths are Debian/Ubuntu-family and Fedora/RHEL-family. Arch/openSUSE/SUSE-family package names, when listed in references, are non-core hints only; do not expand every workflow to those distros unless the user explicitly requests it.

### Ubuntu / WSL Ubuntu

Ubuntu has `language-pack-*` packages. Install English locale support, Simplified/Traditional Chinese packs, and broad CJK fonts:

```bash
sudo apt update -y
sudo apt install -y locales language-pack-en language-pack-zh-hans language-pack-zh-hant fonts-noto-cjk fonts-wqy-zenhei fonts-wqy-microhei
```

### Debian / Minimal Ubuntu Fallback

Debian usually does not use Ubuntu's `language-pack-*` package names. Use `locales` plus CJK fonts:

```bash
sudo apt update -y
sudo apt install -y locales fonts-noto-cjk fonts-wqy-zenhei fonts-wqy-microhei
```

## Generate and Set English UTF-8 Locale

### Debian / Ubuntu

Enable `en_US.UTF-8`, generate locale data, set `LANG`, and remove any stale `LANGUAGE` value:

```bash
sudo sed -i 's/^# *\(en_US.UTF-8 UTF-8\)/\1/' /etc/locale.gen
sudo locale-gen en_US.UTF-8
sudo update-locale LANG=en_US.UTF-8 LANGUAGE
```

Do not set persistent `LC_ALL` by default. If a temporary command needs a forced locale, prefix only that command, for example:

```bash
LC_ALL=en_US.UTF-8 some-command
```

### Fedora / RHEL-family

Install English locale data, Chinese locale data, and broad Noto CJK font coverage. Quote the wildcard so the shell does not expand it before DNF sees it:

```bash
sudo dnf install -y glibc-langpack-en glibc-langpack-zh 'google-noto-*-cjk-fonts'
```

Add WenQuanYi Chinese fonts when available in the enabled repositories. On Fedora the package names are usually `wqy-zenhei-fonts` and `wqy-microhei-fonts`; on RHEL-family systems they may require EPEL or may be unavailable for that release, so query first:

```bash
if dnf repoquery wqy-zenhei-fonts wqy-microhei-fonts >/dev/null 2>&1; then
  sudo dnf install -y wqy-zenhei-fonts wqy-microhei-fonts
else
  echo 'WenQuanYi font packages are not available in the enabled repositories; keep Noto CJK or enable an approved repository first.'
fi
```

If the distro repository does not provide that wildcard set, inspect available packages and fall back to exact package names:

```bash
dnf repoquery 'google-noto-*-cjk-fonts' || true
sudo dnf install -y google-noto-sans-cjk-fonts google-noto-serif-cjk-fonts
```

On Fedora, `default-fonts-cjk` is also a valid broad meta-package when available:

```bash
sudo dnf install -y default-fonts-cjk
```

Set persistent system locale:

```bash
sudo localectl set-locale LANG=en_US.UTF-8
```

If `localectl` is unavailable, write `/etc/locale.conf` explicitly:

```bash
printf 'LANG=en_US.UTF-8\n' | sudo tee /etc/locale.conf
```

## Optional Supplemental Language Packs

Keep the system default locale as `en_US.UTF-8`. When the user requests extra language resources, add language packs and fonts for that language without changing `LANG`.

Use package-manager search first because package names vary by distro and release:

```bash
apt-cache search '^language-pack-(fr|ru)' 2>/dev/null || true
dnf repoquery 'glibc-langpack-fr' 'glibc-langpack-ru' 2>/dev/null || true
```

Common examples:

```bash
# Ubuntu examples
sudo apt install -y language-pack-fr language-pack-ru fonts-noto-core

# Debian examples: keep locales, add broad Noto core fonts; add app-specific translation packages only if needed
sudo apt install -y locales fonts-noto-core

# Fedora / RHEL-family examples
sudo dnf install -y glibc-langpack-fr glibc-langpack-ru google-noto-sans-fonts
```

Guidance:

- For Latin/Cyrillic languages such as French or Russian, `fonts-noto-core` or `google-noto-sans-fonts` is usually enough for broad font coverage.
- For CJK, keep using `fonts-noto-cjk` or the Fedora/RHEL CJK Noto packages.
- For other scripts, search package names instead of guessing; prefer official distro packages.
- Do not change persistent `LANG` away from `en_US.UTF-8` unless the user explicitly asks for a localized default environment.

## Reload and Verify Locale

Open a new login shell, restart the terminal, or source the distro locale file when appropriate:

```bash
[ -r /etc/default/locale ] && . /etc/default/locale
locale
locale -a | grep -i '^en_US\.utf8$\|^en_US\.UTF-8$'
```

Expected:

- `LANG=en_US.UTF-8`
- `LC_ALL` is usually empty/unset unless the user intentionally forced it.
- `en_US.utf8` or `en_US.UTF-8` appears in `locale -a`.

## Timezone and RTC Configuration

Only change timezone after confirming the user's desired behavior.

```bash
sudo timedatectl set-timezone UTC
# or, for UTC+8 civil time:
sudo timedatectl set-timezone Asia/Singapore
```

Verify:

```bash
date
timedatectl status 2>/dev/null || true
```

### Windows/Linux Dual-Boot RTC Mode

On a Windows + Ubuntu/Linux dual-boot machine, clock differences can happen when one OS treats the hardware clock as UTC and the other treats it as local time. Prefer keeping the hardware clock in UTC for Linux-only systems, servers, VMs, WSL, and containers. If the user specifically has Windows/Linux dual-boot time drift and wants Linux to match Windows' local-time RTC behavior, use:

```bash
sudo timedatectl set-local-rtc 1
```

If the current hardware clock value should be treated as authoritative immediately, add:

```bash
sudo timedatectl set-local-rtc 1 --adjust-system-clock
```

Verify:

```bash
timedatectl status
```

To return Linux to the usual UTC RTC mode:

```bash
sudo timedatectl set-local-rtc 0
```

Note: local-time RTC can cause issues around timezone or daylight-saving changes. Use it mainly for physical Windows/Linux dual-boot compatibility, not for WSL, server, container, or automation environments.

If `timedatectl` fails because systemd is unavailable, explain that the environment may be WSL/container/minimal init and use host/runtime-specific configuration instead of forcing edits blindly.

## WSL GUI Rendering: WSLg vs External X Server

Use `references/wsl-integration.md` for full WSLg, external X Server, Windows-to-WSL execution, and default-user command blocks.

### Default Recommendation

For Windows 11 and current WSL 2, prefer WSLg. WSLg supports Linux GUI apps through integrated Wayland/X11 plumbing, Windows desktop integration, clipboard integration, and vGPU-accelerated rendering when drivers are current. External X Servers such as MobaXterm/VcXsrv/Xming remain useful for older Windows builds, WSL 1, SSH-forwarded X11 workflows, or user-specific legacy setups.

### Detect Current GUI Path

Inside WSL:

```bash
echo "DISPLAY=$DISPLAY"
echo "WAYLAND_DISPLAY=$WAYLAND_DISPLAY"
echo "PULSE_SERVER=$PULSE_SERVER"
[ -d /mnt/wslg ] && cat /mnt/wslg/versions.txt || true
ls -la /tmp/.X11-unix 2>/dev/null || true
ls -la /mnt/wslg/.X11-unix 2>/dev/null || true
```

Expected WSLg values commonly include:

```bash
DISPLAY=:0
WAYLAND_DISPLAY=wayland-0
PULSE_SERVER=unix:/mnt/wslg/PulseServer
```

### Switch Current Shell to WSLg

Use this when GUI apps open through an external X Server, window dragging behaves incorrectly, or an existing profile script overwrote WSLg variables:

```bash
export DISPLAY=:0
export WAYLAND_DISPLAY=wayland-0
export PULSE_SERVER=unix:/mnt/wslg/PulseServer
```

If the fix is needed persistently, add it to the user's shell startup only when `/mnt/wslg` exists:

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

### Switch Current Shell to an External X Server

Use this only when the user intentionally wants a Windows-side X Server or WSLg is unavailable. Start the X Server first, allow it through Windows Firewall, and then set `DISPLAY` to the Windows host IP:

```bash
export DISPLAY="$(ip route | awk '/^default/ {print $3; exit}'):0"
unset WAYLAND_DISPLAY
# Keep or unset PULSE_SERVER depending on the audio path the user wants.
```

If the X Server listens on a fixed address or display number, use that explicitly:

```bash
export DISPLAY=<windows-host-ip>:0
```

### Make Switching Easy Without Forcing Persistence

For users who switch often, add shell functions instead of hardcoding one path:

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

### Host-Side WSLg Settings

WSLg GUI support is controlled globally for WSL 2 distributions through `%UserProfile%\.wslconfig`. It is enabled by default on supported WSL versions. If the user has disabled it, restore it with:

```ini
[wsl2]
guiApplications=true
```

Apply host-side WSL changes from PowerShell/CMD:

```powershell
wsl --shutdown
wsl -l -v
```

Wait for the WSL VM to fully stop before relaunching. Use `wsl --terminate <DistroName>` when only one distribution needs to be restarted.

## Optional GUI Runtime and AppImage Support

Use `references/gui-appimage-runtime.md` when the user needs Linux GUI apps, AppImage tools, Electron/Chromium-based utilities, or minimal WSL images that lack common GUI libraries.

Default policy:

- Do not install a full desktop environment unless the user explicitly asks.
- On current Windows 11/WSL 2, use WSLg first; add libraries only when the app reports missing runtime dependencies.
- For AppImage, verify architecture with `uname -m` before downloading `x86_64`, `arm64`/`aarch64`, or other assets. If FUSE is unavailable, prefer installing the distro FUSE compatibility package; on Ubuntu 22.04+ do not install the legacy `fuse` package just to run AppImages. Use `--appimage-extract` as a fallback in restricted WSL/container environments.

## Optional Agent CLI Installation Guidance

Use `references/agent-cli-installation.md` when the user asks to install Claude Code, OpenAI Codex CLI, OpenCode, Hermes, OpenClaw, CC-Switch, `cc-switch-cli`, or similar Agent tooling.

Default policy:

- Do not install Agent CLIs as part of the base locale/font/WSL setup. Keep them optional and requested-tool-specific.
- Re-check official upstream instructions before running network installers, npm global installs, curl scripts, or release downloads when internet access allows. If docs are inaccessible, use the pinned install commands in `references/agent-cli-installation.md` and clearly note that they may have changed. If an official native installer/package-manager path exists, prefer it over npm unless the user specifically wants npm.
- Install under the normal `agent` user whenever possible; avoid global/root installs unless the tool explicitly requires them and the user approves. Install Node.js/npm before npm-based installs, and verify the tool's current minimum Node.js version.
- Record access prerequisites neutrally: some services require supported accounts, subscriptions, API keys, or availability in the user's region/network.

## Create a Least-Privilege Agent User

Prefer a user-chosen password. Avoid embedding shared default passwords in automated setup unless the user explicitly requests it.

```bash
sudo useradd -m -s /bin/bash agent
sudo passwd agent
sudo usermod -aG sudo agent
```

If the user explicitly asks to reproduce the source document's default password:

```bash
echo "agent:cxthhhhh.com" | sudo chpasswd
```

Switch and test sudo:

```bash
su - agent
sudo whoami
```

Expected `sudo whoami` output: `root`.

## WSL User Defaults

For a one-off WSL launch as an existing user from Windows PowerShell/CMD:

```powershell
wsl --distribution <DistributionName> --user agent
```

For Store-installed distributions with a launcher, set the default user:

```powershell
<DistributionName> config --default-user agent
```

Example:

```powershell
ubuntu config --default-user agent
```

If unsure of the distribution name, run:

```powershell
wsl -l -v
```

For imported distributions without a launcher, use `/etc/wsl.conf` only after confirming the distro is imported and the target user exists:

```ini
[user]
default=agent
```

Then restart the distribution from Windows:

```powershell
wsl --terminate <DistributionName>
wsl --distribution <DistributionName> -- whoami
```

## Verification Checklist

```bash
locale
date
printf '中文文件名测试\n' > 中文文件名测试.txt
ls -l 中文文件名测试.txt
cat 中文文件名测试.txt
rm 中文文件名测试.txt
fc-match ':lang=zh-cn' 2>/dev/null || fc-match 'Noto Sans CJK' 2>/dev/null || true
whoami
```

For WSL GUI apps:

```bash
echo "DISPLAY=$DISPLAY WAYLAND_DISPLAY=$WAYLAND_DISPLAY PULSE_SERVER=$PULSE_SERVER"
[ -d /mnt/wslg ] && ls /mnt/wslg/.X11-unix /tmp/.X11-unix 2>/dev/null || true
command -v xclock >/dev/null 2>&1 && xclock &
```

For optional AppImage/Agent CLI setup:

```bash
uname -m
command -v node >/dev/null 2>&1 && node --version || true
command -v npm >/dev/null 2>&1 && npm --version || true
```

Confirm:

- CJK filenames display as text, not `????` or mojibake.
- `LANG` is `en_US.UTF-8`.
- `LC_ALL` is unset unless intentionally forced.
- Timezone and RTC mode match the user's selected behavior.
- Agent sessions run as a non-root user for normal work.
- WSL GUI apps use WSLg by default on modern Windows unless the user selected an external X Server.

## Troubleshooting and Field Notes

### Field Notes from Applying This Skill in WSL

- Multi-line WSL setup commands launched from Windows automation can fail because PowerShell/CMD and Linux shells parse quotes, redirection, variables, and Unicode differently. Write a UTF-8 script file and execute it through `wsl --distribution <Name> --user root -- bash <script>` for complex setup.
- A sandboxed or service-run Agent process may not see the same WSL distributions as the interactive Windows user. If `wsl -l -v` differs between Codex and the user's PowerShell, rerun the WSL commands from the user's Windows session or with the required approval outside the sandbox.
- Imported WSL distributions may start as `root` and may not have a Store launcher that supports `<DistributionName> config --default-user`. Use `/etc/wsl.conf` with `[user] default=agent`, then `wsl --terminate <DistributionName>`.
- WSL configuration changes are not always immediate. Close sessions, wait for WSL to stop, or run `wsl --shutdown`/`wsl --terminate <DistributionName>` before verifying.
- Some WSL/minimal images do not include `sudo`, `locales`, or language packs. Install the missing packages before creating non-root Agent workflows.
- `timedatectl` may require systemd. In WSL, enable systemd in `/etc/wsl.conf` only when needed and restart WSL, or use host/runtime-specific behavior when systemd is unavailable.
- Chinese filename tests can appear as mojibake in automation capture layers even when the WSL locale and terminal are correct. Re-test directly in the user's terminal before changing locale again.

### Common Issues

- If filenames show `????`, verify terminal encoding is UTF-8 and `locale` reports UTF-8 values.
- If GUI apps show boxes/tofu, reinstall Noto CJK plus supplemental WenQuanYi fonts, refresh fontconfig (`fc-cache -fv`), and restart the GUI app/session.
- If `update-locale` is missing, use the Fedora/RHEL `localectl` path or write `/etc/locale.conf` on systemd-based systems.
- If `locale-gen` is missing on Debian/Ubuntu, install `locales`.
- If timezone or RTC changes revert in WSL/containers/managed VMs, document the host/runtime override and configure that layer instead.
- If a WSL GUI app cannot open, verify `DISPLAY=:0`, `/tmp/.X11-unix` points to `/mnt/wslg/.X11-unix`, and `/mnt/wslg/.X11-unix/X0` exists. Do not remove `/tmp/.X11-unix` blindly; inspect it first and prefer backing it up before recreating a WSLg symlink.
- If an external X Server opens GUI windows but dragging/resizing/integration behaves poorly, switch that shell back to WSLg with `export DISPLAY=:0` and `export WAYLAND_DISPLAY=wayland-0`.
- If an AppImage fails with a FUSE error, install the distro FUSE compatibility package (`libfuse2`/`libfuse2t64` on Debian/Ubuntu, `fuse-libs` on Fedora/RHEL-family) or extract it with `--appimage-extract` when FUSE cannot be used.
- If an Electron/Chromium GUI app fails with missing `libgtk`, `libnss3`, `libgbm`, `libasound`, or X11 libraries, load `references/gui-appimage-runtime.md` and install the minimal runtime package set for the distro.
