# Optional Agent CLI Installation Reference

Use this reference only when the user explicitly asks to install Agent CLI or Agent GUI tooling. It is not part of the default locale/font/WSL setup.

## Policy

- Re-check the current official documentation before executing installation commands; installer URLs and package names can change.
- Prefer an official native installer, signed package repository, distro package, or release binary over npm when the tool's own docs recommend that path. Use npm only when the user chooses npm or no native path is appropriate.
- Prefer installing as the normal `agent` user. Avoid running npm global installs or curl installers as `root` unless the tool's official docs require it and the user approves.
- Show network installers before running them when possible. Do not pipe unverified third-party scripts into a shell.
- Record prerequisites neutrally: a tool may require a supported account, subscription, API key, browser login, or service availability in the user's region/network.
- Verify with `--version`, the tool's built-in doctor command, or a harmless help command.

## Common Base Packages

```bash
# Debian/Ubuntu
sudo apt update -y
sudo apt install -y ca-certificates curl git unzip tar xz-utils build-essential

# Fedora/RHEL-family
sudo dnf install -y ca-certificates curl git unzip tar xz gcc gcc-c++ make
```

Install Node.js/npm before npm-based installs. Do not assume the distro's default Node.js is new enough; check `node --version` against the selected tool's current docs. Prefer the official Node.js distribution method selected by the user or distro policy.

```bash
node --version 2>/dev/null || true
npm --version 2>/dev/null || true
```

## Claude Code

Official docs: `https://docs.anthropic.com/en/docs/claude-code/getting-started` and `https://code.claude.com/docs/en/installation` / setup pages. Anthropic documents both a one-line native installer for macOS/Linux/WSL and an npm path. In this skill, prefer the official native installer for Linux/WSL when the user wants fewer Node/npm prerequisites; use npm when the user chooses npm, needs npm version pinning, or the current docs make npm the desired path. The npm path requires Node.js 18+; avoid `sudo npm install -g` because it can create permission and security problems:

```bash
# Native installer
curl -fsSL https://claude.ai/install.sh | bash

# npm installer, requires Node.js 18+ and npm
npm install -g @anthropic-ai/claude-code
```

Verify and repair:

```bash
claude --version
claude doctor
```

Note access prerequisites neutrally: Claude Code requires a usable Anthropic/Claude account path and network/service availability for the user.

## OpenAI Codex CLI

Official upstream: OpenAI `codex` repository / OpenAI Codex documentation. Prefer the official install script or release binary when appropriate; npm is also documented and widely supported.

```bash
# Native installer for Mac/Linux/WSL
curl -fsSL https://chatgpt.com/codex/install.sh | sh

# npm alternative, requires Node.js/npm
npm install -g @openai/codex

codex --version
codex --help
```

Authenticate using the current official OpenAI instructions for the user's selected account/API-key flow.

## OpenCode

Official docs are under the OpenCode website and upstream repository. Re-check the current install page before running commands. Prefer the official install script unless the user asks for a package-manager path. Current common Linux/WSL routes include:

```bash
# Official install script
curl -fsSL https://opencode.ai/install | bash

# npm, requires Node.js/npm
npm install -g opencode-ai

# bun / pnpm / yarn alternatives, when already used by the user
bun install -g opencode-ai
pnpm install -g opencode-ai
yarn global add opencode-ai
```

After installation:

```bash
opencode --version
opencode --help
```

## Hermes Agent

Official docs: `https://hermes-agent.nousresearch.com/docs` and `https://hermes-agent.nousresearch.com/docs/getting-started/installation`. Use the official installer as the preferred Linux/WSL path. Still re-check docs when internet access allows, but keep these commands available for environments that cannot browse documentation.

Prerequisites for Linux/WSL:

```bash
# Debian/Ubuntu
sudo apt update -y
sudo apt install -y git curl xz-utils

# Fedora/RHEL-family
sudo dnf install -y git curl xz
```

Install CLI-only Hermes under the current user:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash
```

If browser automation dependencies are not wanted or cannot be installed in a headless/minimal environment, use the documented skip-browser flag:

```bash
curl -fsSL https://hermes-agent.nousresearch.com/install.sh | bash -s -- --skip-browser
```

Post-install:

```bash
source ~/.bashrc 2>/dev/null || true
hermes doctor
hermes setup
# Fastest Nous Portal path when the user wants that account flow:
hermes setup --portal
```

Notes:

- The installer handles most runtime dependencies itself, including Python, Node.js, ripgrep, and ffmpeg. Do not preinstall Node.js only for Hermes unless the docs or error output require it.
- The normal-user layout places the launcher under `~/.local/bin/hermes`; make sure `~/.local/bin` is in `PATH`.
- Avoid root-mode installation unless the user explicitly wants a shared system install.
- If Playwright/Chromium system libraries are needed and sudo is unavailable, install GUI/browser libraries separately using `references/gui-appimage-runtime.md` or the exact command printed by `hermes doctor`.

## OpenClaw

Official docs: `https://docs.openclaw.ai/` and `https://docs.openclaw.ai/install`. The recommended Linux/WSL2 path is the installer script; it can install Node if needed and run onboarding. Still re-check docs when internet access allows, but keep these commands available for environments that cannot browse documentation.

Recommended install for macOS/Linux/WSL2:

```bash
curl -fsSL https://openclaw.ai/install.sh | bash
```

Install without running onboarding immediately:

```bash
curl -fsSL https://openclaw.ai/install.sh | bash -s -- --no-onboard
```

Local-prefix installer when the user wants OpenClaw and Node kept under a local prefix such as `~/.openclaw`:

```bash
curl -fsSL https://openclaw.ai/install-cli.sh | bash
```

If the user already manages Node.js themselves, npm/pnpm/bun alternatives are documented. OpenClaw currently requires Node.js 22.19+, 23.11+, or 24+; Node 24 is the recommended default.

```bash
node --version

# npm
npm install -g openclaw@latest
openclaw onboard --install-daemon

# pnpm
pnpm add -g openclaw@latest
pnpm approve-builds -g
openclaw onboard --install-daemon

# bun
bun add -g openclaw@latest
openclaw onboard --install-daemon
```

Verify and open dashboard:

```bash
openclaw --version
openclaw doctor
openclaw gateway status
openclaw dashboard
```

Notes:

- On Linux/WSL2, managed startup uses a systemd user service when available. The wizard may need `loginctl enable-linger <user>` and may prompt for sudo.
- Onboarding asks for provider/account/API-key choices. Prepare the user's desired provider credentials before non-interactive setup.
- If `openclaw` is not found after npm-style installation, check `npm prefix -g` and shell `PATH`.
- Do not invent mirror URLs if GitHub/npm/CDN access is blocked; prefer first-party installers, approved internal mirrors, or user-provided package artifacts.

## cc-switch-cli and CC-Switch

For Linux/WSL, prefer `SaladDay/cc-switch-cli` over the CC-Switch GUI AppImage unless the user explicitly needs the GUI. Reasons: it is terminal/TUI-first, avoids AppImage/FUSE/GUI runtime dependencies, and directly fits headless/minimal Agent environments. The installed command is `cc-switch`.

Official upstream: `https://github.com/SaladDay/cc-switch-cli`. It describes itself as a TUI + CLI dual-mode manager for Claude Code, Codex, Gemini, OpenCode, Hermes, and OpenClaw.

Quick install for macOS/Linux:

```bash
curl -fsSL https://github.com/SaladDay/cc-switch-cli/releases/latest/download/install.sh | bash
```

Notes from upstream:

- Installs `cc-switch` to `~/.local/bin` by default. Ensure `~/.local/bin` is in `PATH`.
- Set `CC_SWITCH_INSTALL_DIR` to change the target directory.
- In non-interactive automation, use `CC_SWITCH_FORCE=1` only when the user approves overwriting an existing target.
- On Linux, set `CC_SWITCH_LINUX_LIBC=glibc` if the target needs the glibc build; otherwise the upstream Linux manual examples use musl archives.

Manual Linux install examples:

```bash
# Linux x64
curl -LO https://github.com/SaladDay/cc-switch-cli/releases/latest/download/cc-switch-cli-linux-x64-musl.tar.gz
tar -xzf cc-switch-cli-linux-x64-musl.tar.gz
chmod +x cc-switch
mkdir -p ~/.local/bin
mv cc-switch ~/.local/bin/

# Linux ARM64
curl -LO https://github.com/SaladDay/cc-switch-cli/releases/latest/download/cc-switch-cli-linux-arm64-musl.tar.gz
tar -xzf cc-switch-cli-linux-arm64-musl.tar.gz
chmod +x cc-switch
mkdir -p ~/.local/bin
mv cc-switch ~/.local/bin/
```

Verify:

```bash
cc-switch --version
cc-switch env tools
cc-switch provider list
```

For CC-Switch GUI AppImage releases, use the official `farion1231/cc-switch` GitHub release asset that matches `uname -m` and apply `references/gui-appimage-runtime.md` first if AppImage, FUSE, WSLg, or GUI dependencies are missing.
