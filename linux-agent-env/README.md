# linux-agent-env

`linux-agent-env` is a portable Agent Skill for preparing Linux and WSL Agent workstations.

It focuses on reliable CJK/Chinese filename and GUI font display, an English UTF-8 default locale, WSLg/X Server routing, least-privilege users, developer tooling, Agent CLI installation, GUI management platforms, provider switching, token-saving helpers, and resumable handoff notes for long-running Agent work.

## What it includes

- CJK locale/font setup with Noto CJK and WenQuanYi supplemental fonts
- `LANG=en_US.UTF-8` locale strategy without forcing persistent `LC_ALL`
- WSL-specific guidance for WSLg, external X Servers, default users, and Windows-to-WSL command quoting
- Optional GUI/AppImage/Electron/Tauri runtime libraries
- Optional Node.js, pnpm, Python, terminal-tool, Git/SSH, and WSL workspace setup
- Agent CLI installation guidance for Claude Code, OpenAI Codex CLI, OpenCode, Hermes, OpenClaw, and related tools
- GUI management platform guidance for Orca, Polaris, TOKENICODE, and CloudCLI/claudecodeui
- `cc-switch-cli` provider management and post-install provider/subscription reminders
- Token-saving helper guidance for LeanCTX, Headroom, and RTK
- Session continuity files (`plan.md`, `session-notes.md`, `handoff.md`) to resume long tasks safely

## Package layout

```text
linux-agent-env/
  SKILL.md
  README.md
  .gitignore
  references/
    agent-cli-installation.md
    agent-gui-management.md
    developer-toolchain.md
    gui-appimage-runtime.md
    official-sources.md
    session-continuity.md
    wsl-integration.md
```

## Install

Copy the entire `linux-agent-env/` directory into your Agent skills directory.

For Codex/compatible local skill directories, keep `SKILL.md` and the full `references/` folder together. The `agents/` UI metadata folder is optional and is not required for portable GitHub distribution.

## Usage

Ask your Agent to use `linux-agent-env` when you need to prepare a Linux/WSL Agent environment, install Agent CLIs, add GUI management tools, configure provider switching, or create resumable setup notes.

Example prompts:

```text
Use linux-agent-env to configure this WSL distro for Agent development.
```

```text
Use linux-agent-env to install Claude Code, cc-switch-cli, and a token saver, then create handoff notes.
```

```text
Use linux-agent-env to add a GUI management platform for Codex/Claude sessions on WSL.
```

## Safety notes

- Many workflows modify system packages, users, locale, timezone, WSL defaults, shell startup files, or Agent tools. Run them only with explicit authorization.
- Prefer day-to-day Agent work under a normal user such as `agent`, not `root`.
- Do not store API keys, passwords, private SSH keys, tokens, or cookies in handoff notes.
- Re-check upstream official docs before running network installers when internet access is available.

## Release hygiene

Before publishing, include only this skill directory and avoid committing generated state such as `.agent-state/`, backups, logs, caches, `node_modules/`, or build output. The included `.gitignore` covers these common local artifacts.

## Attribution

Original source concept and authorship: CXT, MeowLove - `WWW.CXTHHHHH.COM`.
