# Official Source Notes

Use these links when auditing or updating this skill.

- Ubuntu `update-locale` manpage: `update-locale` updates global locale settings and accepts assignments such as `LANG=en_CA.UTF-8`; variables passed without values are removed from the locale file.
  https://manpages.ubuntu.com/manpages/noble/man8/update-locale.8.html
- Linux `locale(7)` manpage: locale resolution checks `LC_ALL` first, then category variables, then `LANG`; this is why the skill avoids persistent `LC_ALL` by default.
  https://man7.org/linux/man-pages/man7/locale.7.html
- systemd `localectl` manpage: `localectl` queries/changes system locale; `set-locale` accepts `LANG=en_US.UTF-8` style assignments and edits `/etc/locale.conf` via systemd-localed.
  https://www.freedesktop.org/software/systemd/man/latest/localectl.html
- `timedatectl(1)` manpage: `set-local-rtc 1` maintains RTC in local time; the manpage recommends UTC mode when possible and documents `--adjust-system-clock` behavior.
  https://man7.org/linux/man-pages/man1/timedatectl.1.html
- Microsoft WSL basic commands: WSL can run a distro as a specific user with `wsl --distribution <Distribution Name> --user <User Name>` and can set a Store distro's default user with `<DistributionName> config --default-user <Username>`.
  https://learn.microsoft.com/en-us/windows/wsl/basic-commands
- Microsoft WSL advanced configuration: `wsl.conf` is per-distro, `.wslconfig` is global for WSL 2, WSL config changes require WSL restart timing, and `guiApplications` controls WSLg support.
  https://learn.microsoft.com/en-us/windows/wsl/wsl-config
- Microsoft WSL GUI apps tutorial: WSL supports Linux GUI apps through WSLg for X11 and Wayland on supported Windows/WSL versions; WSL 2 is required for GUI apps.
  https://learn.microsoft.com/en-us/windows/wsl/tutorials/gui-apps
- Microsoft WSLg README: WSLg provides the X server, Wayland server, and PulseAudio server; WSL preconfigures `DISPLAY`, `WAYLAND_DISPLAY`, and `PULSE_SERVER` for the user distro.
  https://github.com/microsoft/wslg
- Microsoft WSLg display troubleshooting: WSLg's X server uses display `:0`; `/tmp/.X11-unix` should map to `/mnt/wslg/.X11-unix`; collect `/mnt/wslg/versions.txt` and `weston.log` for diagnosis.
  https://github.com/microsoft/wslg/wiki/Diagnosing-%22cannot-open-display%22-type-issues-with-WSLg
- Ubuntu package `fonts-noto-cjk`: Noto CJK fonts with large Unicode coverage.
  https://packages.ubuntu.com/noble/fonts-noto-cjk
- Debian package `fonts-noto-cjk`: includes Noto Sans/Serif/Mono CJK families for Simplified Chinese, Traditional Chinese, Japanese, and Korean.
  https://packages.debian.org/bookworm/fonts-noto-cjk
- Ubuntu package `fonts-noto-core`: Noto core fonts with broad Unicode coverage for many non-CJK scripts.
  https://packages.ubuntu.com/noble/fonts/fonts-noto-core
- Debian package `fonts-noto-core`: Noto core font families.
  https://packages.debian.org/bookworm/fonts-noto-core
- Fedora packages: `glibc-langpack-en`, `glibc-langpack-zh`, and Noto font packages provide locale data and fonts.
  https://packages.fedoraproject.org/pkgs/glibc/glibc-langpack-en/
  https://packages.fedoraproject.org/pkgs/glibc/glibc-langpack-zh/
  https://packages.fedoraproject.org/pkgs/google-noto-sans-cjk-fonts/google-noto-sans-cjk-fonts/index.html
  https://packages.fedoraproject.org/pkgs/google-noto-fonts/google-noto-sans-fonts/index.html
- Ubuntu package `language-pack-en`: English translation updates; optional for locale generation but useful when installing Ubuntu language packs consistently.
  https://packages.ubuntu.com/noble/language-pack-en
- Ubuntu package `language-pack-zh-hans`: Simplified Chinese translation updates; Ubuntu-specific language-pack package, not a Debian package.
  https://packages.ubuntu.com/search?keywords=language-pack-zh-hans
- Red Hat DNF documentation: many DNF commands accept glob expressions; quote or escape wildcard expressions so the shell does not expand them first.
  https://docs.redhat.com/en/documentation/red_hat_enterprise_linux/10/html/managing_software_with_the_dnf_tool/searching-for-rhel-content#specifying-glob-expressions-in-dnf-input_searching-for-rhel-content
- Fedora `default-fonts-cjk`: meta-package for sans/serif/mono/emoji/math default fonts for CJK languages.
  https://packages.fedoraproject.org/pkgs/langpacks/default-fonts-cjk/
- Claude Code skills docs: a skill is a directory with required `SKILL.md` and optional supporting files; personal skills live under `~/.claude/skills/<skill-name>/SKILL.md`.
  https://code.claude.com/docs/en/skills

- Microsoft PowerShell parsing documentation: native commands are parsed by PowerShell first, with special rules for argument mode, metacharacters, quoting, and stop-parsing behavior.
  https://learn.microsoft.com/en-us/powershell/module/microsoft.powershell.core/about/about_parsing

- Microsoft WSL command reference: `wsl --distribution`, `--user`, `--exec`, `--cd`, `--shutdown`, and related command-line options document how Windows launches commands inside WSL.
  https://learn.microsoft.com/en-us/windows/wsl/basic-commands

## Supplemental fonts, GUI runtime, AppImage, and optional Agent tooling

- Ubuntu `fonts-wqy-zenhei` / `fonts-wqy-microhei`: WenQuanYi Zen Hei and Micro Hei Chinese font packages are available as distro packages; use alongside Noto CJK when Chinese GUI compatibility matters.
  https://packages.ubuntu.com/search?keywords=fonts-wqy-zenhei
  https://packages.ubuntu.com/search?keywords=fonts-wqy-microhei
- Debian `fonts-wqy-zenhei` / `fonts-wqy-microhei`: Debian carries the same WenQuanYi package names for supported releases.
  https://packages.debian.org/search?keywords=fonts-wqy-zenhei
  https://packages.debian.org/search?keywords=fonts-wqy-microhei
- Fedora WenQuanYi packages: Fedora package names use the `wqy-*-fonts` naming pattern, commonly `wqy-zenhei-fonts` and `wqy-microhei-fonts` when present in enabled repositories.
  https://packages.fedoraproject.org/search?query=wqy-zenhei-fonts
  https://packages.fedoraproject.org/search?query=wqy-microhei-fonts
- Optional Song/Ming/Kai-style Chinese fonts: Debian/Ubuntu commonly provide AR PL UMing/UKai as `fonts-arphic-uming` and `fonts-arphic-ukai`; Fedora-family systems commonly use `cjkuni-uming-fonts` and `cjkuni-ukai-fonts` when available.
  https://packages.debian.org/search?keywords=fonts-arphic-uming
  https://packages.debian.org/search?keywords=fonts-arphic-ukai
  https://packages.fedoraproject.org/search?query=cjkuni-uming-fonts
  https://packages.fedoraproject.org/search?query=cjkuni-ukai-fonts
- AppImage FUSE troubleshooting: AppImage docs explain FUSE requirements, FUSE 2 compatibility packages, and `--appimage-extract` as a fallback.
  https://docs.appimage.org/user-guide/troubleshooting/fuse.html
- Playwright Linux dependency docs: `install-deps` exists because headless/browser GUI stacks depend on GTK/NSS/audio/GBM/X11-style libraries; this is a useful upstream checklist for minimal images.
  https://playwright.dev/docs/browsers#install-system-dependencies
- Electron Linux docs: Electron apps require Linux desktop/runtime libraries such as GTK/NSS and X11/audio integrations depending on app features.
  https://www.electronjs.org/docs/latest/development/build-instructions-linux
- Claude Code official docs: setup pages document Native Install as the recommended macOS/Linux/WSL path, signed apt/dnf/apk repositories, npm as an advanced option, current Node.js requirements for npm, and the warning not to use `sudo npm install -g`.
  https://code.claude.com/docs/en/overview
  https://code.claude.com/docs/en/setup
- OpenAI Codex CLI official upstream: documents the native Mac/Linux install script, Windows PowerShell install script, npm package `@openai/codex`, Homebrew cask, and release binaries.
  https://github.com/openai/codex
- OpenCode official docs: documents the install script as the easiest path, plus npm/bun/pnpm/yarn and Homebrew/Arch options.
  https://opencode.ai/docs/
- Hermes Agent official docs/homepage: documents the Linux/macOS/WSL2 CLI installer `curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash`, Windows PowerShell installer, normal-user layout under `~/.local/bin/hermes`, prerequisites (`git`, `curl`, `xz-utils` on Linux), `--skip-browser`, `hermes doctor`, and `hermes setup --portal`.
  https://hermes-agent.nousresearch.com/
  https://hermes-agent.nousresearch.com/docs
  https://hermes-agent.nousresearch.com/docs/getting-started/installation
  https://hermes-agent.nousresearch.com/docs/getting-started/platform-support
- OpenClaw official docs: documents Node.js requirements, recommended Linux/WSL2 installer `curl -fsSL https://openclaw.ai/install.sh | bash`, `--no-onboard`, local-prefix `install-cli.sh`, npm/pnpm/bun alternatives, `openclaw onboard --install-daemon`, `openclaw doctor`, and gateway/dashboard verification.
  https://docs.openclaw.ai/
  https://docs.openclaw.ai/install
  https://docs.openclaw.ai/start/getting-started
  https://docs.openclaw.ai/start/wizard-cli-reference
- CC-Switch official GitHub project/releases: download only matching architecture release assets.
  https://github.com/farion1231/cc-switch

- Arch Linux package database / ArchWiki Simplified Chinese localization: common package names include `noto-fonts-cjk`, `wqy-zenhei`, and `wqy-microhei`.
  https://archlinux.org/packages/extra/any/wqy-zenhei/
  https://archlinux.org/packages/extra/any/wqy-microhei/
  https://wiki.archlinux.org/title/Localization_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)/Simplified_Chinese_(%E7%AE%80%E4%BD%93%E4%B8%AD%E6%96%87)
- openSUSE/SUSE package databases: common names include `google-noto-sans-cjk-fonts`, `wqy-zenhei-fonts`, and `wqy-microhei-fonts`.
  https://packagehub.suse.com/packages/wqy-zenhei-fonts/
  https://software.opensuse.org/package/wqy-microhei-fonts
  https://software.opensuse.org/download.html?package=google-noto-sans-cjk-fonts&project=M17N%3Afonts
- SaladDay/cc-switch-cli official GitHub project: Linux/WSL should prefer this terminal/TUI CLI over the CC-Switch GUI AppImage unless GUI is explicitly needed. Upstream documents the quick installer, `~/.local/bin` target, `CC_SWITCH_INSTALL_DIR`, `CC_SWITCH_FORCE`, `CC_SWITCH_LINUX_LIBC`, and x64/ARM64 tarball names.
  https://github.com/SaladDay/cc-switch-cli
