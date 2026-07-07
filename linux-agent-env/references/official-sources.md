# Official Source Notes

Use these links when auditing or updating this skill.

- Ubuntu `update-locale` manpage: `update-locale` updates global locale settings and accepts assignments such as `LANG=en_CA.UTF-8`; variables passed without values are removed from the locale file.
  https://manpages.ubuntu.com/manpages/noble/man8/update-locale.8.html
- Linux `locale(7)` manpage: locale resolution checks `LC_ALL` first, then category variables, then `LANG`; this is why the skill avoids persistent `LC_ALL` by default.
  https://man7.org/linux/man-pages/man7/locale.7.html
- systemd `localectl` manpage: `localectl` queries/changes system locale; `set-locale` accepts `LANG=en_US.UTF-8` style assignments and edits `/etc/locale.conf` via systemd-localed.
  https://manpages.debian.org/bookworm/systemd/localectl.1.en.html
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
- Claude Code official docs: setup pages document Native Install as the recommended macOS/Linux/WSL path, package-manager/native managed-install options, npm as an advanced option, current Node.js requirements for npm, and the warning not to use `sudo npm install -g`. In this skill, the default Linux/WSL path is the one-line native install script unless the user explicitly chooses managed package repositories.
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

- SaladDay/cc-switch-cli official GitHub project: Linux/WSL should prefer this terminal/TUI CLI over the CC-Switch GUI AppImage unless GUI is explicitly needed. Upstream documents the quick installer, `~/.local/bin` target, `CC_SWITCH_INSTALL_DIR`, `CC_SWITCH_FORCE`, `CC_SWITCH_LINUX_LIBC`, and x64/ARM64 tarball names.
  https://github.com/SaladDay/cc-switch-cli

- Token-saving helper projects to verify before installation because names, commands, and integration points can change quickly:
  - LeanCTX: search/use the current official LeanCTX upstream README or user-provided source before installing.
  - Headroom: search/use the current official Headroom upstream docs/README before installing.
  - RTK / Rust Token Killer: search/use the current official RTK upstream docs/README before installing.

- Node.js and npm installation: npm docs recommend installing Node.js/npm through a Node version manager where possible; for Linux installer flows, they list NodeSource and Node.js downloads. Node.js download page identifies the current LTS line.
  https://docs.npmjs.com/downloading-and-installing-node-js-and-npm/
  https://nodejs.org/en/download
  https://github.com/nodesource/distributions
- pnpm installation: official docs document standalone POSIX installer, Corepack enable flow, updating Corepack first, and current Node.js compatibility.
  https://pnpm.io/installation
- uv installation: official Astral docs document the standalone installer, pipx installation, self-update, and shell completion.
  https://docs.astral.sh/uv/getting-started/installation/
- pipx installation: official pipx docs recommend distro package manager use on Linux and note PEP 668 externally-managed Python behavior.
  https://pipx.pypa.io/latest/how-to/install-pipx/
- LeanCTX official docs: universal installer, npm alternative, `lean-ctx onboard`/`setup`, diagnostics, CLI operations, bypass/raw mode, and agent integration commands.
  https://leanctx.com/docs/getting-started/
  https://leanctx.com/docs/cli-reference/
- Headroom official docs/PyPI: Python package `headroom-ai`, `pipx install --python python3.13 "headroom-ai[all]"`, Python 3.10+ requirement, CLI commands, proxy/MCP/wrap flows, and persistent install commands.
  https://headroomlabs.ai/
  https://headroomlabs-ai.github.io/headroom/cli/
  https://pypi.org/project/headroom-ai/
  https://github.com/headroomlabs-ai/headroom
- RTK / Rust Token Killer official docs: verify this is `rtk-ai/rtk`, install via official script, check `rtk gain`, initialize hooks with `rtk init -g` or agent-specific flags, and use compact command wrappers such as `rtk read`, `rtk grep`, and `rtk pytest`.
  https://www.rtk-ai.app/
  https://github.com/rtk-ai/rtk
  https://github.com/rtk-ai/rtk/blob/develop/INSTALL.md

- NodeSource binary distributions: use after verifying the desired current LTS major; setup scripts follow the `setup_<major>.x` pattern for Debian/RPM families.
  https://github.com/nodesource/distributions

- Agent GUI management platforms:
  - Orca (`stablyai/orca`): desktop ADE/orchestrator for Codex, ClaudeCode, OpenCode, Pi; releases include Linux `.deb`, `.rpm`, AppImage, Windows installer, and macOS DMG/ZIP assets.
    https://github.com/stablyai/orca
    https://www.onorca.dev/download
  - Polaris (`misxzaiz/Polaris`): Tauri 2 desktop app and standalone web service for OpenAI Codex CLI / Claude Code CLI; `pnpm run package:web` creates `polaris-web/`; default web port documented as `9830`.
    https://github.com/misxzaiz/Polaris
    https://github.com/misxzaiz/Polaris/blob/main/docs/deployment/README.md
  - TOKENICODE (`yiliqi78/TOKENICODE`): Claude Code desktop GUI; README documents macOS `.dmg`, Windows `.msi`/`.exe`, and Linux `.AppImage`/`.deb`/`.rpm` release assets, plus Tauri source build.
    https://github.com/yiliqi78/TOKENICODE
  - CloudCLI / claudecodeui (`siteboon/claudecodeui`): web/mobile UI for Claude Code, Cursor CLI, Codex, and Gemini CLI; README documents `npx @cloudcli-ai/cloudcli`, global npm install, default `http://localhost:3001`, and Node.js v22+ requirement.
    https://github.com/siteboon/claudecodeui
    https://cloudcli.ai
- Tauri v2 Linux prerequisites: use for source-building Polaris/TOKENICODE or similar Tauri apps; package names vary by distro and should be checked against current Tauri docs.
  https://v2.tauri.app/start/prerequisites/

- Git identity and SSH setup: Git's first-time setup docs cover `user.name`, `user.email`, and editor/default configuration; GitHub SSH docs document generating Ed25519 SSH keys, adding them to accounts, and testing SSH authentication.
  https://git-scm.com/book/en/v2/Getting-Started-First-Time-Git-Setup
  https://git-scm.com/docs/git-config
  https://docs.github.com/en/authentication/connecting-to-github-with-ssh/generating-a-new-ssh-key-and-adding-it-to-the-ssh-agent
  https://docs.github.com/en/authentication/connecting-to-github-with-ssh/adding-a-new-ssh-key-to-your-github-account
  https://docs.github.com/en/authentication/connecting-to-github-with-ssh/testing-your-ssh-connection

- Session continuity / handoff file mechanics: GNU `mktemp` documents safe temporary directory creation; Git `gitignore`/exclude docs cover local ignore files such as `.git/info/exclude` for untracked state directories.
  https://www.gnu.org/software/coreutils/manual/html_node/mktemp-invocation.html
  https://git-scm.com/docs/gitignore
