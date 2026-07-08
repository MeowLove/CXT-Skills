---
name: linux-agent-env
description: Prepare Linux and WSL Agent workstations end-to-end: base CJK/Chinese font and filename support, English UTF-8 locale, WSL distribution preflight, WSLg/X Server routing, GUI/AppImage/Electron/Tauri runtime support, least-privilege users, Node/Python/terminal/Git/SSH developer toolchains, official-native Agent CLI installation, cc-switch provider setup, provider/proxy/protocol mismatch troubleshooting for GUI/IDE/service/Windows-to-WSL launchers, optional GUI management platforms, token-saving helpers, and resumable handoff notes. Use for Debian/Ubuntu/WSL and Fedora/RHEL-family setup, LANG=en_US.UTF-8, Claude Code/Codex/OpenCode/Hermes/OpenClaw/Gemini/cc-switch-cli/LeanCTX/Headroom/RTK/Orca/Polaris/TOKENICODE/CloudCLI planning, WSL admin, and root/sudo system configuration.
metadata:
  version: 3.0.2
  source_url: https://github.com/MeowLove/CXT-Skills/tree/main/linux-agent-env
  source_repo: MeowLove/CXT-Skills
  source_path: linux-agent-env
---

# Linux Agent Environment Setup

Source attribution: CXT, MeowLove — `WWW.CXTHHHHH.COM`.

## v3 Architecture

This Skill is now an orchestrated Linux/WSL Agent environment toolkit. Keep `SKILL.md` as the routing and safety layer; load the smallest required reference file for the requested task. Do not load every reference by default.

Core design goals:

1. **Safe system administration**: detect first, ask/confirm when required, avoid destructive WSL/user/package operations.
2. **Stable base environment**: install UTF-8 locale data and CJK fonts, keep persistent `LANG=en_US.UTF-8`, avoid forcing persistent `LC_ALL` unless explicitly requested.
3. **WSL-aware execution**: preflight WSL distro existence, account context, Windows-to-WSL quoting, WSLg/external-X routing, and default-user behavior.
4. **Agent workstation layering**: base OS → WSL/GUI runtime → developer toolchain → Agent CLI → provider switching → token/context tools → verification/handoff.
5. **Real launcher verification**: provider success is not proven until the same GUI/IDE/service/Windows-to-WSL launcher that will run the Agent has been tested.

## Reference Loading Map

Load only the relevant files:

| Need | Load |
|---|---|
| Base Linux/WSL locale, fonts, timezone, RTC, normal user, base verification | `references/base-linux-setup.md` |
| WSL distro existence checks, Windows-to-WSL command patterns, WSLg vs external X Server, WSL default user | `references/wsl-integration.md` |
| Minimal GUI/AppImage/Electron/Tauri/Playwright runtime libraries | `references/gui-appimage-runtime.md` |
| Node.js LTS/npm/corepack/pnpm, Python tools, terminal utilities, Git/SSH, WSL workspace dirs | `references/developer-toolchain.md` |
| Claude Code, Codex CLI, OpenCode, Hermes, OpenClaw, cc-switch-cli, token savers | `references/agent-cli-installation.md` |
| Stable Agent CLI paths, cc-switch provider lifecycle, provider mismatch/proxy/protocol/debugging | `references/agent-provider-operations.md` |
| Orca, Polaris, TOKENICODE, CloudCLI/claudecodeui GUI management platforms | `references/agent-gui-management.md` |
| Long tasks, context compression, resumable plan/session/handoff files | `references/session-continuity.md` |
| Source links and upstream verification notes | `references/official-sources.md` |

## Recommended Execution Pipeline

Use this order for a complete or one-click Agent workstation. If the user asks for only one layer, do only that layer and prerequisites.

1. **Session continuity**: for long or risky tasks, load `references/session-continuity.md` and create a unique state directory with `plan.md`, `session-notes.md`, and `handoff.md` before context gets crowded.
2. **Detect and preflight**:
   - Linux: `cat /etc/os-release`, `id`, `whoami`, `locale`, `locale -a`, `date`.
   - WSL: also check distro existence/default user from Windows before create/import/install.
   - GUI: inspect `DISPLAY`, `WAYLAND_DISPLAY`, `PULSE_SERVER`, `/mnt/wslg`, and X11 sockets.
3. **Base environment**: load `references/base-linux-setup.md`; install locale data and fonts, set `LANG=en_US.UTF-8`, verify CJK filename/font behavior.
4. **WSL integration**: if target is WSL, load `references/wsl-integration.md`; prefer WSLg on modern Windows 11/WSL 2; use external X Server only when intentionally needed.
5. **GUI runtime**: if GUI/AppImage/Electron/Tauri/Playwright is needed, load `references/gui-appimage-runtime.md`; install minimal runtime libraries, not a full desktop environment by default.
6. **Least-privilege user**: create/use a normal `agent` user when appropriate. In one-click/default mode with no password supplied, use `agent` / `cxthhhhh.com`. Never configure an empty password or passwordless sudo unless explicitly requested.
7. **Developer toolchain**: for a complete Agent workstation or project work, load `references/developer-toolchain.md`; install Node.js LTS/npm/corepack/pnpm, Python CLI tools, terminal tools, Git/SSH, and WSL ext4 workspace directories as needed.
8. **Agent CLI installation**: load `references/agent-cli-installation.md`; install requested tools as the normal user. Prefer each tool's official native installer/script or official release binary first. Use npm/pip/apt/dnf/apk only when the user chooses it, the tool has no native path, version isolation is needed, or current upstream docs explicitly select that path.
9. **Provider switching**: after an Agent CLI install, recommend `cc-switch-cli` (`cc-switch` command). Add/select a provider, subscription, account, or API-key profile with app-scoped commands such as `cc-switch --app <app> provider add` and `cc-switch --app <app> provider switch <id>`.
10. **Real-execution verification**: if the CLI is launched by Orca, CloudCLI, Polaris, TOKENICODE, VS Code, JetBrains, Windows Terminal, services, CI, or Windows-to-WSL wrappers, load `references/agent-provider-operations.md` and test from that exact launcher environment.
11. **Token/context helpers**: recommend one token saver by default. Default: LeanCTX. Alternatives: Headroom or RTK. Install only one unless the user wants comparison.
12. **Final verification and handoff**: show versions, paths, locale, current provider, live config, proxy/listener status when relevant, GUI URL/app status, and next manual login/API-key/subscription steps. Update `handoff.md` for long tasks.

## Guardrails

- Ask for explicit user approval before changing packages, locale, timezone, RTC mode, users, passwords, sudo groups, WSL defaults, persistent shell startup files, or installing Agent CLIs.
- Treat WSL create/import/unregister as high-risk. If a target distro name may already exist, stop and run the WSL existence preflight; do not retry creation blindly.
- Prefer a normal user for day-to-day Agent work. Avoid running Agents as `root` unless the specific task requires root.
- Do not store API keys, tokens, cookies, private SSH keys, passwords, or full auth files in logs or handoff notes. Redact before sharing diagnostics.
- Prefer stable user-level command paths such as `~/.local/bin/<tool>` and verify with `type -a`, `command -v`, `readlink -f`, and `--version`.
- For provider work, do not trust `cc-switch provider current` alone. Inspect the target Agent live config and run a real minimal request.
- For Windows-to-WSL automation, avoid complex one-liners. Write a UTF-8 script, strip CRLF, run it inside the named distro/user, and capture output to WSL-side logs.
- If network access is available and the task involves current Agent installers, release binaries, or package names, re-check the upstream official source before running commands.

## Mandatory Minimal Checks

Run these before changing the system:

```bash
cat /etc/os-release
id
whoami
echo "HOME=$HOME"
echo "PATH=$PATH"
locale || true
locale -a | grep -E 'en_US\.utf8|en_US\.UTF-8|C\.UTF-8' || true
date
```

For WSL targets, also run from Windows PowerShell/CMD:

```powershell
wsl --status
wsl --list --all --verbose
wsl --list --quiet
```

If the user names a WSL distro, load `references/wsl-integration.md` and run the registry/name preflight before create/import/install.

## Completion Report Format

When finished, report:

```text
Environment: distro/version, WSL yes/no, user/HOME
Base: locale, fonts, timezone/RTC changes, CJK filename/font test
WSL/GUI: WSLg or X Server route, DISPLAY/WAYLAND_DISPLAY, GUI runtime if installed
Toolchain: Node/Python/terminal/Git/SSH/workspace changes if installed
Agents: installed CLIs, paths, versions, doctor/help result
Providers: cc-switch app, current provider, live config checked, proxy/listener status if needed
Token/context: selected token saver or skipped
Manual next steps: login, API key, subscription/provider add, restart launcher, or reboot/reopen terminal
Handoff: state directory and files updated, if used
```

## Troubleshooting Router

- Filename `????`, mojibake, or tofu boxes: load `references/base-linux-setup.md`.
- WSL distro already exists, `wsl -l` looks empty/garbled, or Agent sandbox sees different distros: load `references/wsl-integration.md`.
- GUI app cannot open, external X Server cannot drag/resize, AppImage FUSE error, Electron/Tauri missing libs: load `references/wsl-integration.md` and/or `references/gui-appimage-runtime.md`.
- Agent CLI missing, resolves to root/npm/apt version, fails in non-interactive shells, or provider switch behaves inconsistently: load `references/agent-provider-operations.md`.
- `cc-switch` looks correct but real Agent execution uses the wrong endpoint/account/model/key/proxy/protocol/user/config or returns empty output/logs: load `references/agent-provider-operations.md`.
- Private repo clone/push fails: load `references/developer-toolchain.md` for Git identity and SSH.
- Context is crowded or work may be interrupted: load `references/session-continuity.md`.
