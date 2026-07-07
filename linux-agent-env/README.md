# linux-agent-env

Current release marker: `2.3.1`

This repository release is intended as `v2.3.1`. Use the matching Git tag for stable installs after tagging the repository.

`linux-agent-env` is a portable Agent Skill for preparing Linux and WSL Agent workstations.

It focuses on reliable CJK/Chinese filename and GUI font display, an English UTF-8 default locale, WSLg/X Server routing, least-privilege users, developer tooling, Agent CLI installation, GUI management platforms, provider switching, token-saving helpers, and resumable handoff notes for long-running Agent work.

## What it includes

- CJK locale/font setup with Noto CJK and WenQuanYi supplemental fonts
- `LANG=en_US.UTF-8` locale strategy without forcing persistent `LC_ALL`
- WSL-specific guidance for WSLg, external X Servers, default users, and Windows-to-WSL command quoting
- Optional GUI/AppImage/Electron/Tauri runtime libraries
- Optional Node.js, pnpm, Python, terminal-tool, Git/SSH, and WSL workspace setup
- Agent CLI installation guidance for Claude Code, OpenAI Codex CLI, OpenCode, Hermes, OpenClaw, and related tools
- Agent CLI operational checklist for stable user paths, PATH, symlinks, non-interactive shells, and cc-switch/Codex provider verification
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
    agent-cli-operational-checklist.md
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


### Install from GitHub with Codex skill-installer

Use the GitHub **tree** URL for the subdirectory:

```text
https://github.com/MeowLove/CXT-Skills/tree/main/linux-agent-env
```

Do not use the browser URL without `/tree/<branch>/`:

```text
https://github.com/MeowLove/CXT-Skills/linux-agent-env
```

That URL is not a valid GitHub web directory path and normally returns 404. GitHub web directory links include `/tree/<branch>/<path>`. Some installers may parse `https://github.com/<owner>/<repo>/<path>` as a repo-plus-subpath shorthand, but the portable, user-facing import URL should be the `/tree/main/linux-agent-env` URL.

Equivalent installer parameters are:

```bash
install-skill-from-github.py --repo MeowLove/CXT-Skills --path linux-agent-env --ref main
```

For reproducible releases, create a Git tag and install from that tag, for example:

```bash
install-skill-from-github.py --repo MeowLove/CXT-Skills --path linux-agent-env --ref v2.3.1
```

or use the tagged tree URL:

```text
https://github.com/MeowLove/CXT-Skills/tree/v2.3.1/linux-agent-env
```

### Updating and version checks

There is no universal Skill update marker that every Agent client honors. In Codex-style skills, `name` and `description` are the fields used for discovery/selection; the optional `metadata.version` in `SKILL.md` is a human/Agent release marker, not a guaranteed update mechanism.

The current bundled GitHub installer copies the selected GitHub directory into `$CODEX_HOME/skills/<skill-name>` and refuses to overwrite an existing destination. If a client shows an **Update** button for GitHub-installed skills, that update behavior is controlled by the client/installer's stored source metadata or marketplace mechanism, not by `SKILL.md` frontmatter alone. Manual copy installs may not show an update button.

Recommended update workflow:

1. Keep `metadata.version` in `SKILL.md` and this README's release marker in sync.
2. Commit changes to `main` for the latest channel.
3. Create Git tags such as `v2.3.1`, `v2.3.2`, `v2.4.0` for reproducible installs.
4. For manual updates, compare the local `metadata.version` and, when needed, reinstall from GitHub after removing or backing up the old local skill directory.
5. For client-managed updates, install from the GitHub tree URL rather than copying files manually so the client has a chance to remember the source.

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
