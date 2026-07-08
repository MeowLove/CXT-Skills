# linux-agent-env

Current release marker: `3.2.1`

`linux-agent-env` is a portable Agent Skill for preparing Linux and WSL Agent workstations.

It covers reliable CJK/Chinese filename and GUI font display, English UTF-8 default locale, WSLg/X Server routing, least-privilege users, developer tooling, Agent CLI installation, GUI management platforms, provider switching, provider mismatch/proxy/protocol diagnostics, token-saving helpers, and resumable handoff notes for long-running Agent work.

## What it includes

- Base CJK locale/font setup with Noto CJK and WenQuanYi supplemental fonts
- `LANG=en_US.UTF-8` locale strategy without forcing persistent `LC_ALL`
- WSL-specific guidance for distro existence preflight, WSLg, external X Servers, default users, and Windows-to-WSL command quoting
- Optional GUI/AppImage/Electron/Tauri/Playwright runtime libraries
- Optional Node.js, pnpm, Python, terminal-tool, Git/SSH, and WSL workspace setup
- Agent CLI installation guidance for Claude Code, OpenAI Codex CLI, OpenCode, Hermes, OpenClaw, cc-switch-cli, and related tools
- Provider operations for stable user paths, PATH, symlinks, non-interactive shells, cc-switch provider lifecycle, live config verification, proxy/protocol troubleshooting, and external launcher mismatch debugging
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

Copy the complete `linux-agent-env/` directory into the target Agent's skills directory. Keep `SKILL.md`, `README.md`, `CHANGELOG.md`, `.gitignore`, and the full `references/` directory together.

GitHub latest URL:

```text
https://github.com/MeowLove/CXT-Skills/tree/main/linux-agent-env
```

Stable tagged URL after publishing `v3.2.1`:

```text
https://github.com/MeowLove/CXT-Skills/tree/v3.2.1/linux-agent-env
```

For Codex skill-installer compatible flows, the equivalent parameters are:

```bash
install-skill-from-github.py --repo MeowLove/CXT-Skills --path linux-agent-env --ref main
# or, after tagging:
install-skill-from-github.py --repo MeowLove/CXT-Skills --path linux-agent-env --ref v3.2.1
```

Do not use `https://github.com/MeowLove/CXT-Skills/linux-agent-env`; GitHub web directory links require `/tree/<branch>/<path>`.

## Usage

Tell the Agent to use `linux-agent-env` and state the target, for example: configure a WSL distro, install Agent CLIs, add provider switching, debug provider mismatch, or create resumable handoff notes. The Skill's `SKILL.md` routes the Agent to the required reference file.

## Updating and version checks

There is no universal Skill update marker that every Agent client honors. Keep `metadata.version` in `SKILL.md`, this README marker, Git tags, and `CHANGELOG.md` synchronized. For reproducible installs, install from a tag such as `v3.2.1`; for latest installs, use `main`.

## Safety notes

- Many workflows modify system packages, users, locale, timezone, WSL defaults, shell startup files, or Agent tools. Run them only with explicit authorization.
- Prefer day-to-day Agent work under a normal user such as `agent`, not `root`.
- Do not store API keys, passwords, private SSH keys, tokens, cookies, or full auth files in handoff notes or public logs.
- Re-check upstream official docs before running network installers when internet access is available.

## Release hygiene

Before publishing, include only this skill directory and avoid committing generated state such as `.agent-state/`, backups, logs, caches, `node_modules/`, or build output.

Suggested release commands from the repository root:

```bash
git add linux-agent-env
git commit -m "Release linux-agent-env v3.2.1"
git tag v3.2.1
git push
git push origin v3.2.1
```

## Attribution

Original source concept and authorship: CXT, MeowLove - `WWW.CXTHHHHH.COM`.

## 更新历史

README only keeps the compact major-version history. See [CHANGELOG.md](CHANGELOG.md) for the fuller release notes.

- **v3.x** - Current major line. Rebuilt as an engineered Linux/WSL Agent environment toolkit: concise `SKILL.md` router, modular references, official-source rechecks, provider/launcher mismatch playbooks, GUI management guidance, resumable handoff workflow, and stricter official-native installer precedence.
- **v2.x** - Expanded from base locale setup into a practical Agent workstation installer: WSLg/X Server guidance, normal-user policy, developer toolchains, Agent CLI installation, cc-switch app-scoped provider operations, token savers, GitHub install/update/version notes, and real-world WSL/provider troubleshooting.
- **v1.x local versions** - Started as a local Linux/WSL CJK environment setup Skill: install Chinese/CJK language and font support for Debian/Ubuntu and RHEL-family systems, keep an English `en_US.UTF-8` runtime locale, set Singapore/UTC timezone options, and create a least-privilege `agent` user for daily Agent work.
