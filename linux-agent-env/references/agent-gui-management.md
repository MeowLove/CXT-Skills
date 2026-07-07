# Optional Agent GUI Management Platforms

Use this reference when the user wants a graphical/web control layer for Agent CLIs after the base Linux/WSL environment and at least one Agent CLI are installed. These tools change quickly; re-check upstream release assets and README before downloading or executing installers.

## Policy

- Prefer official release assets or official npm packages over building from source. Build from source only when no suitable binary exists or the user is developing the GUI itself.
- Install and run under the normal `agent` user whenever possible. Avoid running GUI/web management platforms as `root`.
- Treat web UIs as local control planes: bind to `127.0.0.1` by default when supported, avoid exposing `0.0.0.0` to a LAN/WAN without authentication, firewalling, or a reverse proxy.
- For WSL: prefer browser/Web UI control surfaces for headless/minimal systems; use WSLg for desktop apps on current Windows 11/WSL 2. If a Tauri/Electron/AppImage GUI fails, load `references/gui-appimage-runtime.md` first.
- Verify required CLIs before launching a GUI: `claude --version`, `codex --version`, `opencode --version`, `hermes --version`, `openclaw --version`, or the tool-specific command.
- GUI managers may read/write Agent config directories such as `~/.claude`, project workspaces, MCP settings, API endpoints, and session history. Back up important config before testing a new manager.
- Respect licenses. In particular, CloudCLI/claudecodeui is AGPL-3.0; modified network-service deployments can require source disclosure.

## Selection Guide

| Tool | Best fit | Primary form | Supported/advertised agents | Notes |
|---|---|---|---|---|
| Orca (`stablyai/orca`) | Full desktop orchestrator for multiple agents and worktrees | Desktop app, release assets | Codex, ClaudeCode, OpenCode, Pi; mobile companion | Best for local desktop/WSLg users who want parallel worktrees and terminal splits. |
| Polaris (`misxzaiz/Polaris`) | Claude/Codex GUI with desktop and server/browser modes | Tauri desktop or standalone web server | OpenAI Codex CLI, Claude Code CLI | Web package is useful for WSL/server/no-GUI environments; default web port is `9830`. |
| TOKENICODE (`yiliqi78/TOKENICODE`) | Claude Code-focused desktop client with provider/API presets | Tauri desktop, release assets | Claude Code CLI | Good for Claude-specific desktop/session/permission workflows; Linux assets may lag latest release, so inspect releases. |
| CloudCLI / claudecodeui (`siteboon/claudecodeui`) | Browser/mobile UI for local or remote Agent sessions | npm package/self-hosted web server; desktop companion for macOS/Windows | Claude Code, Cursor CLI, Codex, Gemini CLI | Easiest self-hosted web UI: `npx @cloudcli-ai/cloudcli`; requires Node.js v22+. |

## Common Prerequisites

For web/npm managers, load `references/developer-toolchain.md` and make sure Node.js is current enough. CloudCLI currently documents Node.js v22+ for `npx @cloudcli-ai/cloudcli`.

```bash
node --version
npm --version
pnpm --version 2>/dev/null || true
```

For Tauri desktop development/builds, install Rust plus Tauri Linux prerequisites. Verify current Tauri docs before changing the package list.

```bash
# Debian/Ubuntu Tauri v2 build prerequisites
sudo apt update -y
sudo apt install -y build-essential curl wget file libssl-dev libxdo-dev librsvg2-dev patchelf

if apt-cache show libwebkit2gtk-4.1-dev >/dev/null 2>&1; then
  sudo apt install -y libwebkit2gtk-4.1-dev
elif apt-cache show libwebkit2gtk-4.0-dev >/dev/null 2>&1; then
  sudo apt install -y libwebkit2gtk-4.0-dev
else
  echo 'No WebKitGTK dev package found; check current Tauri Linux prerequisites for this distro release.'
fi

if apt-cache show libayatana-appindicator3-dev >/dev/null 2>&1; then
  sudo apt install -y libayatana-appindicator3-dev
elif apt-cache show libappindicator3-dev >/dev/null 2>&1; then
  sudo apt install -y libappindicator3-dev
fi

# Fedora/RHEL-family Tauri v2 build prerequisites
sudo dnf install -y openssl-devel curl wget file libxdo-devel librsvg2-devel patchelf gcc gcc-c++ make

if dnf list --available webkit2gtk4.1-devel >/dev/null 2>&1 || dnf list --installed webkit2gtk4.1-devel >/dev/null 2>&1; then
  sudo dnf install -y webkit2gtk4.1-devel
elif dnf list --available webkit2gtk4.0-devel >/dev/null 2>&1 || dnf list --installed webkit2gtk4.0-devel >/dev/null 2>&1; then
  sudo dnf install -y webkit2gtk4.0-devel
else
  echo 'No WebKitGTK devel package found; check current Tauri Linux prerequisites for this distro release.'
fi

if dnf list --available libappindicator-gtk3-devel >/dev/null 2>&1 || dnf list --installed libappindicator-gtk3-devel >/dev/null 2>&1; then
  sudo dnf install -y libappindicator-gtk3-devel
fi
```


Install Rust with rustup only when building Tauri apps from source:

```bash
curl --proto '=https' --tlsv1.2 -sSf https://sh.rustup.rs | sh
. "$HOME/.cargo/env"
rustc --version
cargo --version
```

For runtime-only AppImage/Electron/Tauri issues, use `references/gui-appimage-runtime.md` instead of installing the full build toolchain.

## Orca (`stablyai/orca`)

Upstream: `https://github.com/stablyai/orca`; homepage/download page: `https://www.onorca.dev/download`.

Use Orca when the user wants a desktop orchestrator for parallel Agent worktrees, terminals, source control, and mobile companion monitoring. Prefer official desktop release assets:

- Debian/Ubuntu: `orca-ide_<version>_amd64.deb` or `orca-ide_<version>_arm64.deb`
- Fedora/RHEL-family: `orca-ide-<version>.x86_64.rpm` or `orca-ide-<version>.aarch64.rpm`
- Portable Linux: `orca-linux.AppImage` or `orca-linux-arm64.AppImage`
- Windows/macOS: use official `.exe`/`.dmg` assets or download page

Install examples after downloading the matching asset:

```bash
uname -m

# Debian/Ubuntu .deb
sudo apt install ./orca-ide_*_amd64.deb
# or arm64:
# sudo apt install ./orca-ide_*_arm64.deb

# Fedora/RHEL-family .rpm
sudo dnf install ./orca-ide-*.x86_64.rpm
# or aarch64:
# sudo dnf install ./orca-ide-*.aarch64.rpm

# AppImage fallback
chmod +x ./orca-linux*.AppImage
./orca-linux*.AppImage
```

Notes:

- For WSL, use WSLg and `references/gui-appimage-runtime.md` before running the AppImage.
- Do not hardcode a release version; select the latest stable release asset matching `uname -m`.
- If building from source, use `pnpm install` and project scripts only after reading upstream developer docs; release assets are the normal user path.

## Polaris (`misxzaiz/Polaris`)

Upstream: `https://github.com/misxzaiz/Polaris`.

Use Polaris when the user wants a GUI for OpenAI Codex CLI and Claude Code CLI, especially when a WSL/server browser-accessible web mode is useful.

### Prefer prebuilt release when available

Polaris releases may include:

- `polaris-web-<version>-linux-x86_64.tar.gz` for Linux web/server use
- `polaris-web-<version>-win-x64.zip` / macOS web bundles
- Windows `.msi` desktop installer

For Linux/WSL web bundle:

```bash
tar -xzf polaris-web-*-linux-x86_64.tar.gz
cd polaris-web
chmod +x polaris-web start.sh stop.sh 2>/dev/null || true
./polaris-web --host 127.0.0.1 --port 9830
# browser: http://localhost:9830
```

If the packaged `start.sh` is preferred:

```bash
./start.sh
```

### Build web mode from source

Use this when no matching release asset exists or the user wants current source:

```bash
git clone https://github.com/misxzaiz/Polaris.git
cd Polaris
pnpm install
pnpm run package:web
cd polaris-web
./polaris-web --host 127.0.0.1 --port 9830
```

Polaris web mode notes:

- Default documented listener is `0.0.0.0:9830`; bind `127.0.0.1` for local-only use when possible.
- Custom port: `./polaris-web --port 8080` or `POLARIS_WEB_PORT=8080 ./polaris-web`.
- Keep the binary and `dist/` in the same `polaris-web/` directory or the UI may return 404.
- Native binaries are platform/architecture-specific and should be built on the target platform or compatible glibc baseline.

Desktop development/build:

```bash
pnpm install
pnpm run tauri:dev
pnpm run tauri:build
```

## TOKENICODE (`yiliqi78/TOKENICODE`)

Upstream: `https://github.com/yiliqi78/TOKENICODE`.

Use TOKENICODE when the user wants a Claude Code-focused desktop client with session management, file explorer/editor, permission workflow, MCP/skill management, and provider/API preset UI.

Prefer official release assets. README documents macOS `.dmg`, Windows `.msi`/`.exe`, and Linux `.AppImage`/`.deb`/`.rpm`; however, the newest GitHub release may temporarily contain only a subset of platforms. If the latest release lacks Linux assets, inspect recent stable releases and choose the newest matching Linux asset instead of building blindly.

Install examples after downloading the matching asset:

```bash
uname -m

# Debian/Ubuntu .deb
sudo apt install ./TOKENICODE_*_amd64.deb

# Fedora/RHEL-family .rpm
sudo dnf install ./TOKENICODE-*.x86_64.rpm

# AppImage fallback
chmod +x ./TOKENICODE_*_amd64.AppImage
./TOKENICODE_*_amd64.AppImage
```

Source/dev path when the user wants to build:

```bash
git clone https://github.com/yiliqi78/TOKENICODE.git
cd TOKENICODE
pnpm install
pnpm tauri dev
# production build:
pnpm tauri build
```

Notes:

- TOKENICODE is Claude-focused; verify `claude --version` first even if the app can guide first-run installation.
- For Linux desktop/WSL, WebKitGTK/Tauri runtime issues should be handled through `references/gui-appimage-runtime.md` and Tauri prerequisites above.
- Some provider presets or mirror update paths are region/network conveniences; still let the user choose their account/provider credentials.

## CloudCLI / claudecodeui (`siteboon/claudecodeui`)

Upstream: `https://github.com/siteboon/claudecodeui`; docs/homepage: `https://cloudcli.ai`.

Use CloudCLI when the user wants a browser/mobile UI for existing local/remote Agent sessions. It is the simplest self-hosted web option and does not require WSLg.

Quick run with npm package (requires Node.js v22+ according to upstream README):

```bash
node --version
npx @cloudcli-ai/cloudcli
# browser: http://localhost:3001
```

Global install for regular use:

```bash
npm install -g @cloudcli-ai/cloudcli
cloudcli
cloudcli status
cloudcli version
```

Environment/config notes from upstream `.env.example`:

```bash
# Typical local defaults/knobs
SERVER_PORT=3001
VITE_PORT=5173
# Optional when the binary is not on PATH:
# CLAUDE_CLI_PATH=claude
```

Remote/WSL usage:

```bash
# Prefer local-only binding if supported by current CloudCLI config.
cloudcli
# From Windows browser, open http://localhost:3001 for WSL2 localhost forwarding.

# For a remote Linux box, prefer SSH tunneling instead of exposing the port:
ssh -L 3001:127.0.0.1:3001 user@remote-host
```

Notes:

- Upstream README says local CloudCLI auto-discovers existing sessions and supports Claude Code, Cursor CLI, Codex, and Gemini CLI.
- Desktop companion releases are mainly macOS/Windows; Linux users should normally use the npm/self-hosted web UI.
- The project license is AGPL-3.0-or-later; if you modify it and provide it as a network service, check source-disclosure obligations.

## Verification Checklist

```bash
# Required Agent CLIs
claude --version 2>/dev/null || true
codex --version 2>/dev/null || true
opencode --version 2>/dev/null || true

# Web UI ports
ss -ltnp 2>/dev/null | grep -E ':(3001|5173|9830)\b' || true

# WSL GUI path for desktop apps
echo "DISPLAY=$DISPLAY WAYLAND_DISPLAY=$WAYLAND_DISPLAY PULSE_SERVER=$PULSE_SERVER"
[ -d /mnt/wslg ] && ls /mnt/wslg/.X11-unix /tmp/.X11-unix 2>/dev/null || true
```

If a GUI manager opens but cannot find sessions or tools, verify PATH and config from the same user account that runs the GUI:

```bash
whoami
echo "$PATH"
command -v claude codex opencode cloudcli 2>/dev/null || true
ls -la ~/.claude 2>/dev/null || true
```
