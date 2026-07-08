# linux-agent-env

Current release marker: `3.0.2`

This repository release is intended as `v3.0.2`. Use the matching Git tag for stable installs after tagging the repository.

`linux-agent-env` is a portable Agent Skill for preparing Linux and WSL Agent workstations.

It covers reliable CJK/Chinese filename and GUI font display, English UTF-8 default locale, WSLg/X Server routing, least-privilege users, developer tooling, Agent CLI installation, GUI management platforms, provider switching, provider mismatch/proxy/protocol diagnostics, token-saving helpers, and resumable handoff notes for long-running Agent work.

## Release notes

### v3.0.2

- Removed the temporary v2 compatibility redirect files after verifying active references now point to `references/agent-provider-operations.md`.
- Re-checked Agent CLI and GUI management install guidance against current official sources on 2026-07-08.
- Corrected Claude Code guidance: official docs currently list npm as the standard install path, while the native binary installer is marked Alpha; the Skill now presents npm as the strict official-standard path and native installer as an official Alpha/no-Node alternative.
- Kept Codex guidance dual-path: OpenAI/openai-codex GitHub documents the standalone macOS/Linux installer, while OpenAI Help/Developer docs still emphasize npm; the Skill now calls out both as official and warns to keep install method consistent.
- Confirmed cc-switch app-scoped commands, supported app IDs, and default `~/.local/bin` install behavior from SaladDay/cc-switch-cli.
- Confirmed CloudCLI Node.js v22+ / `npx @cloudcli-ai/cloudcli`, Orca release/download guidance, Polaris `package:web` flow and requirements, and TOKENICODE Linux package/WebKitGTK notes.

### v3.0.1

- Reorganized the Skill as an engineered, layered toolkit: concise `SKILL.md` router plus task-specific references.
- Moved base locale/font/time/user commands into `references/base-linux-setup.md`.
- Merged provider path, cc-switch, proxy, protocol, live-config, GUI/IDE/service launcher, and PowerShell-to-WSL mismatch field notes into `references/agent-provider-operations.md`.
- Clarified the complete execution pipeline: session continuity, base setup, WSL/GUI, least-privilege user, developer toolchain, Agent CLI, provider switching, real launcher verification, token saver, final handoff.

### v2.5.1

- Aligned the release marker and tagged install examples to `v2.5.1`.
- Kept `cc-switch-cli` examples app-scoped by default with `cc-switch --app <app> provider ...`.
- Included WSL distribution existence preflight guidance to prevent repeated same-name create/import attempts when Agent sandbox output is empty, garbled, or inconsistent with the user's interactive PowerShell session.
- Added a detailed real-world provider mismatch playbook for cases where `cc-switch` looks correct but GUI/IDE/service/Windows-to-WSL launchers still use the wrong account, endpoint, model, protocol, proxy, user, config directory, or produce empty output/logs.

## What it includes

- Base CJK locale/font setup with Noto CJK and WenQuanYi supplemental fonts
- `LANG=en_US.UTF-8` locale strategy without forcing persistent `LC_ALL`
- WSL-specific guidance for distro existence preflight, WSLg, external X Servers, default users, and Windows-to-WSL command quoting
- Optional GUI/AppImage/Electron/Tauri/Playwright runtime libraries
- Optional Node.js, pnpm, Python, terminal-tool, Git/SSH, and WSL workspace setup
- Agent CLI installation guidance for Claude Code, OpenAI Codex CLI, OpenCode, Hermes, OpenClaw, cc-switch-cli, and related tools
- Agent provider operations for stable user paths, PATH, symlinks, non-interactive shells, cc-switch provider lifecycle, live config verification, proxy/protocol troubleshooting, and external launcher mismatch debugging
- GUI management platform guidance for Orca, Polaris, TOKENICODE, and CloudCLI/claudecodeui
- Token-saving helper guidance for LeanCTX, Headroom, and RTK
- Session continuity files (`plan.md`, `session-notes.md`, `handoff.md`) to resume long tasks safely

## Package layout

```text
linux-agent-env/
  SKILL.md
  README.md
  .gitignore
  references/
    base-linux-setup.md
    wsl-integration.md
    gui-appimage-runtime.md
    developer-toolchain.md
    agent-cli-installation.md
    agent-provider-operations.md
    agent-gui-management.md
    session-continuity.md
    official-sources.md
```

## Install

Copy the entire `linux-agent-env/` directory into your Agent skills directory.

For Codex/compatible local skill directories, keep `SKILL.md` and the full `references/` folder together. The `agents/` UI metadata folder is optional and is not required for portable GitHub distribution.

### Install from GitHub with Codex skill-installer

Use the GitHub **tree** URL for the subdirectory:

```text
https://github.com/MeowLove/CXT-Skills/tree/main/linux-agent-env
```

Do not use the browser URL without `/tree/<branch>/`:

```text
https://github.com/MeowLove/CXT-Skills/linux-agent-env
```

That URL is not a valid GitHub web directory path and normally returns 404. GitHub web directory links include `/tree/<branch>/<path>`.

Equivalent installer parameters are:

```bash
install-skill-from-github.py --repo MeowLove/CXT-Skills --path linux-agent-env --ref main
```

For reproducible releases, create a Git tag and install from that tag, for example:

```bash
install-skill-from-github.py --repo MeowLove/CXT-Skills --path linux-agent-env --ref v3.0.2
```

or use the tagged tree URL:

```text
https://github.com/MeowLove/CXT-Skills/tree/v3.0.2/linux-agent-env
```

### Updating and version checks

There is no universal Skill update marker that every Agent client honors. In Codex-style skills, `name` and `description` are the fields used for discovery/selection; the optional `metadata.version` in `SKILL.md` is a human/Agent release marker, not a guaranteed update mechanism.

Recommended update workflow:

1. Keep `metadata.version` in `SKILL.md` and this README's release marker in sync.
2. Commit changes to `main` for the latest channel.
3. Create Git tags such as `v3.0.2`, `v3.0.3`, `v3.1.0` for reproducible installs.
4. For manual updates, compare the local `metadata.version` and reinstall from GitHub after removing or backing up the old local skill directory.
5. For client-managed updates, install from the GitHub tree URL rather than copying files manually so the client has a chance to remember the source.

## Usage

Ask your Agent to use `linux-agent-env` when you need to prepare a Linux/WSL Agent environment, install Agent CLIs, add GUI management tools, configure provider switching, debug provider mismatch, or create resumable setup notes.

Example prompts:

```text
Use linux-agent-env to configure this WSL distro for Agent development.
```

```text
Use linux-agent-env to install Claude Code, cc-switch-cli, and a token saver, then create handoff notes.
```

```text
Use linux-agent-env to diagnose why cc-switch shows the right Codex provider but CloudCLI/Orca/Windows-to-WSL still launches the wrong provider or returns empty output.
```

## Safety notes

- Many workflows modify system packages, users, locale, timezone, WSL defaults, shell startup files, or Agent tools. Run them only with explicit authorization.
- Prefer day-to-day Agent work under a normal user such as `agent`, not `root`.
- Do not store API keys, passwords, private SSH keys, tokens, cookies, or full auth files in handoff notes or public logs.
- Re-check upstream official docs before running network installers when internet access is available.

## Release hygiene

Before publishing, include only this skill directory and avoid committing generated state such as `.agent-state/`, backups, logs, caches, `node_modules/`, or build output. The included `.gitignore` covers these common local artifacts.

Suggested release commands from the repository root:

```bash
git add linux-agent-env
git commit -m "Release linux-agent-env v3.0.2"
git tag v3.0.2
git push
git push origin v3.0.2
```

## Attribution

Original source concept and authorship: CXT, MeowLove - `WWW.CXTHHHHH.COM`.
