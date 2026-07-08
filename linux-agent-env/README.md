# linux-agent-env

Current release marker: `3.1.0`

This repository release is intended as `v3.1.0`. Use the matching Git tag for stable installs after tagging the repository.

`linux-agent-env` is a portable Agent Skill for preparing Linux and WSL Agent workstations.

It covers reliable CJK/Chinese filename and GUI font display, English UTF-8 default locale, WSLg/X Server routing, least-privilege users, developer tooling, Agent CLI installation, GUI management platforms, provider switching, provider mismatch/proxy/protocol diagnostics, token-saving helpers, and resumable handoff notes for long-running Agent work.

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
  CHANGELOG.md
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
install-skill-from-github.py --repo MeowLove/CXT-Skills --path linux-agent-env --ref v3.1.0
```

or use the tagged tree URL:

```text
https://github.com/MeowLove/CXT-Skills/tree/v3.1.0/linux-agent-env
```

### Updating and version checks

There is no universal Skill update marker that every Agent client honors. In Codex-style skills, `name` and `description` are the fields used for discovery/selection; the optional `metadata.version` in `SKILL.md` is a human/Agent release marker, not a guaranteed update mechanism.

Recommended update workflow:

1. Keep `metadata.version` in `SKILL.md` and this README's release marker in sync.
2. Commit changes to `main` for the latest channel.
3. Create Git tags such as `v3.1.0`, `v3.1.1`, `v3.2.0` for reproducible installs.
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
git commit -m "Release linux-agent-env v3.1.0"
git tag v3.1.0
git push
git push origin v3.1.0
```

## Attribution

Original source concept and authorship: CXT, MeowLove - `WWW.CXTHHHHH.COM`.

## 更新历史

README only keeps the compact major-version history. See [CHANGELOG.md](CHANGELOG.md) for the fuller release notes.

- **v3.x** - Current major line. Rebuilt as an engineered Linux/WSL Agent environment toolkit: concise `SKILL.md` router, modular references, official-source rechecks, provider/launcher mismatch playbooks, GUI management guidance, and resumable handoff workflow.
- **v2.x** - Expanded from base locale setup into a practical Agent workstation installer: WSLg/X Server guidance, normal-user policy, developer toolchains, Agent CLI installation, cc-switch app-scoped provider operations, token savers, GitHub install/update/version notes, and real-world WSL/provider troubleshooting.
- **v1.x local versions** - Started as a local Linux/WSL CJK environment setup Skill: install Chinese/CJK language and font support for Debian/Ubuntu and RHEL-family systems, keep an English `en_US.UTF-8` runtime locale, set Singapore/UTC timezone options, and create a least-privilege `agent` user for daily Agent work.
