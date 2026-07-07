# Optional Agent CLI Installation Reference

Use this reference only when the user explicitly asks to install Agent CLI, Agent GUI tooling, provider switching, or token-saving helpers. It is not part of the default locale/font/WSL setup.

## Policy

- Re-check the current official documentation before executing installation commands; installer URLs and package names can change.
- Prefer every tool's official native installer/script or official release binary first when available. Use npm, pip, pipx, apt, dnf, or apk only when the user chooses that method, the tool has no native path, version pinning/isolation is needed, or current upstream docs make it the selected path.
- Do not interpret "native installer" as "use apt/dnf/apk" by default. A signed package repository is a managed-update path that should be used only when the user wants it or the current docs explicitly select it for the task.
- Prefer installing as the normal `agent` user. Avoid running npm global installs or curl installers as `root` unless the tool's official docs require it and the user approves.
- Show network installers before running them when possible. Do not pipe unverified third-party scripts into a shell.
- Record prerequisites neutrally: a tool may require a supported account, subscription, API key, browser login, or service availability in the user's region/network.
- Verify with `--version`, the tool's built-in doctor command, or a harmless help command.
- After installing any Agent CLI, run or load `references/agent-cli-operational-checklist.md` when the environment is WSL, non-interactive, externally controlled, or has mixed root/user installs. Recommend `cc-switch-cli` (command `cc-switch`) and one token-saving helper. Default recommendation: LeanCTX; alternatives: Headroom and RTK.

## Recommended Post-Agent Add-ons

After any Agent CLI installation succeeds:

1. Recommend `cc-switch-cli` on Linux/WSL so the user can manage providers from the terminal. After installing it, remind the user to add/select a provider, subscription, account, or API-key profile before expecting Agent calls to work.
2. Recommend installing **one** token-saving helper. Default: **LeanCTX**. Alternatives: **Headroom** and **RTK**.
3. Do not stack multiple token savers by default; hooks/proxies can overlap and hide important raw output. Install more than one only when the user intentionally wants to compare them.
4. Do not install these automatically unless the user requested a complete Agent toolchain or approved the add-ons.
5. Verify the selected add-ons with harmless commands such as `--version`, `--help`, `cc-switch --app <app> provider current`, or tool-specific doctor commands.

## Common Base Packages

```bash
# Debian/Ubuntu
sudo apt update -y
sudo apt install -y ca-certificates curl git unzip tar xz-utils build-essential

# Fedora/RHEL-family
sudo dnf install -y ca-certificates curl git unzip tar xz gcc gcc-c++ make
```

Install Node.js/npm before npm-based installs. Do not assume the distro's default Node.js is new enough; check `node --version` against the selected tool's current docs. For a complete workstation, use `references/developer-toolchain.md` to install Node.js LTS, npm, corepack, and pnpm. Prefer the official Node.js distribution method selected by the user or distro policy.

```bash
node --version 2>/dev/null || true
npm --version 2>/dev/null || true
```

## Claude Code

Official docs: `https://docs.anthropic.com/en/docs/claude-code/getting-started` and `https://code.claude.com/docs/en/setup` / installation pages. Anthropic documents a one-line native installer for macOS/Linux/WSL, npm as an alternative, and package-manager/native managed-install options on some pages. In this skill, prefer the official native installer script for Linux/WSL by default. Use npm when the user chooses npm, needs npm version pinning, or the current docs make npm the desired path. Use apt/dnf/apk repository installation only when the user explicitly wants managed package updates or the current official docs make that path the selected one. The npm path requires a current supported Node.js version; avoid `sudo npm install -g` because it can create permission and security problems:

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

Verify command paths, then configure next steps. For full PATH/symlink/provider checks, use `references/agent-cli-operational-checklist.md`:

```bash
cc-switch --version
cc-switch env tools
cc-switch --app claude provider list
cc-switch --app claude provider current
cc-switch --app codex provider list
cc-switch --app codex provider current
```

If no provider is configured yet, prompt the user for the desired provider/subscription/account/API-key path and run:

```bash
cc-switch --app <app> provider add
cc-switch --app <app> provider list
cc-switch --app <app> provider switch <id>
cc-switch --app <app> provider current
```


Supported app identifiers for current cc-switch-cli examples include `claude`, `codex`, `gemini`, `opencode`, `hermes`, and `openclaw`. Use the exact upstream identifier; avoid hyphenated guesses such as `open-code` or `open-claw` unless the installed version explicitly documents aliases.

For app-specific commands, prefer the upstream/global app selector form:

```bash
cc-switch --app claude provider list
cc-switch --app claude provider current
cc-switch --app claude provider add
cc-switch --app claude provider switch <id>
cc-switch --app codex provider list
cc-switch --app codex provider current
```

Common provider commands to keep available without re-searching. Prefer the app-scoped form; replace `<app>` with `claude`, `codex`, `gemini`, `opencode`, `hermes`, or `openclaw`:

```bash
cc-switch --app <app> provider list              # List providers for the target app
cc-switch --app <app> provider current           # Show current provider for the target app
cc-switch --app <app> provider add               # Add new provider for the target app
cc-switch --app <app> provider edit <id>         # Edit existing provider for the target app
cc-switch --app <app> provider switch <id>       # Switch provider for the target app
cc-switch --app <app> provider delete <id>       # Delete provider for the target app
cc-switch --app <app> provider stream-check <id> # Run stream health check for the target app
cc-switch --app <app> provider fetch-models <id> # Fetch remote model list for the target app
cc-switch --app <app> provider duplicate <id>    # Duplicate an existing provider when supported
cc-switch --app <app> provider export <id>       # Export provider config when supported
cc-switch --app <app> provider speedtest         # Compare provider latency/speed when supported
cc-switch env tools                              # Show detected Agent tools
cc-switch env check --app <app>                  # Check environment conflicts for one app
cc-switch env list --app <app>                   # List relevant environment/config items for one app
```

Use the interactive TUI when configuration is easier than flags:

```bash
cc-switch
```

Post-install handoff reminder:

```text
cc-switch is installed. Next, add or select a provider/subscription/API-key profile with `cc-switch --app <app> provider add` or `cc-switch --app <app> provider switch <id>`, then verify with `cc-switch --app <app> provider current` and optionally `cc-switch --app <app> provider stream-check <id>`.
```

For CC-Switch GUI AppImage releases, use the official `farion1231/cc-switch` GitHub release asset that matches `uname -m` and apply `references/gui-appimage-runtime.md` first if AppImage, FUSE, WSLg, or GUI dependencies are missing.

## Token-Saving Helpers

Recommend exactly one token saver after the user has an Agent CLI working. Default choice: **LeanCTX**. Use Headroom or RTK when the user prefers their workflow or the selected Agent/toolchain documents better compatibility. Because these tools may change prompts, context, shell wrappers, MCP/tooling, request routing, or raw command output, explain the tradeoff and verify on harmless commands before using them for important work.

### Decision Order

1. **LeanCTX** - default recommendation for general Agent context/token reduction. Official docs provide a universal installer and `lean-ctx onboard` for auto-configuring many tools including Claude Code, Codex CLI, Hermes, OpenClaw, OpenCode, Gemini CLI, and others.
2. **Headroom** - alternative when the user wants a Python-based proxy/MCP/wrapper workflow for Claude/Codex/OpenClaw-style traffic and has a suitable Python runtime.
3. **RTK / Rust Token Killer** - alternative when the user primarily wants command-output compression through shell hooks or explicit `rtk` command wrappers. Verify this is `rtk-ai/rtk`, not the unrelated Rust Type Kit package.

Installation policy:

- Re-check the current official README/docs when internet access allows.
- If docs are unavailable, do not invent mirror URLs. Use only pinned first-party commands below, approved internal mirrors, or user-provided release artifacts.
- Install under the normal `agent` user where possible.
- Install only one token saver by default. If a token saver modifies shell hooks or provider URLs, document how to bypass or undo it before enabling another one.
- After install, run `--version`/`--help` and a small dry-run or documented doctor/check command before wiring it into Agent startup.

### LeanCTX Default Path

Install with the official universal installer:

```bash
curl -fsSL https://leanctx.com/install.sh | sh
```

If the user wants to inspect the installer first or avoid a source build, download and run it explicitly:

```bash
curl -fsSL https://leanctx.com/install.sh -o install.sh
chmod +x install.sh
./install.sh --download
```

Alternative when Node.js/npm is already managed and the user prefers npm:

```bash
npm install -g lean-ctx-bin
```

Common setup and verification:

```bash
lean-ctx --version
lean-ctx onboard              # recommended zero-question setup
lean-ctx setup                # guided wizard alternative
lean-ctx doctor --fix
lean-ctx doctor integrations  # integration checks when available
lean-ctx status
lean-ctx status --json
```

Common operations:

```bash
lean-ctx -c "git status"           # run and compress shell output
lean-ctx exec "pytest -q"          # alias style for command execution
lean-ctx bypass "git diff HEAD~1"  # guaranteed raw/uncompressed output
lean-ctx read src/main.rs -m auto
lean-ctx read src/main.rs -m lines:10-50
lean-ctx grep "TODO" .
lean-ctx update
```

Non-interactive/CI/container style:

```bash
lean-ctx bootstrap
lean-ctx init --global
lean-ctx init --agent claude   # replace with codex, hermes, openclaw, opencode, etc. when supported
```

### Headroom Alternative

Headroom requires Python 3.10+. Prefer `pipx` isolation for a CLI tool. If Python 3.13 is available, upstream recommends it for full dollar-savings reporting; Python 3.14 can track token savings but may not support every pricing dependency.

```bash
python3 --version
pipx --version
pipx install --python python3.13 "headroom-ai[all]" || pipx install "headroom-ai[all]"
```

Fallback when `pipx` is not available and the user accepts a user-site install:

```bash
python3 -m pip install --user "headroom-ai[all]"
```

Common setup and operations:

```bash
headroom --version
headroom --help
headroom proxy                    # local proxy, default port 8787
headroom proxy --port 8787
headroom mcp install
headroom mcp status
headroom wrap claude              # start proxy and launch Claude Code
headroom wrap codex               # start proxy and launch Codex CLI
headroom wrap openclaw
headroom perf
headroom learn
headroom learn --apply
```

Persistent deployment commands:

```bash
headroom install apply
headroom install status
headroom install start
headroom install stop
headroom install restart
headroom install remove
```

### RTK / Rust Token Killer Alternative

Pre-check first to avoid installing the unrelated Rust Type Kit package:

```bash
rtk --version 2>/dev/null || true
rtk gain 2>/dev/null || true
command -v rtk || true
```

If `rtk gain` works, do not reinstall. If `rtk --version` works but `rtk gain` fails, the wrong `rtk` may be installed; remove it only after user approval.

Official quick install for Linux/macOS:

```bash
curl -fsSL https://raw.githubusercontent.com/rtk-ai/rtk/master/install.sh | sh
```

Verify and initialize for the selected Agent:

```bash
rtk --version
rtk gain
rtk init -g                  # Claude Code / default hook path
rtk init -g --codex          # Codex
rtk init --agent hermes      # Hermes
rtk init --agent cline       # Cline/Roo-style tools when supported
```

Common commands:

```bash
rtk ls .
rtk read file.rs
rtk read file.rs -l aggressive
rtk find "*.rs" .
rtk grep "pattern" .
rtk git status
rtk git diff
rtk pytest
rtk cargo test
rtk pnpm list
rtk gain --graph
rtk gain --history
rtk discover
rtk session
```

Minimal handoff prompt after any Agent CLI install:

```text
Next recommended add-ons: install cc-switch-cli for provider switching, then choose one token saver. Default token saver recommendation: LeanCTX. Alternatives: Headroom or RTK.
```
