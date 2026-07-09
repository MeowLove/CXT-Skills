# linux-agent-env

Current release marker: `4.0.2`

`linux-agent-env` is a portable Agent Skill for preparing Linux and WSL Agent workstations.

It covers reliable CJK/Chinese filename and GUI font display, English UTF-8 default locale, WSLg/X Server routing, least-privilege users, developer tooling, Agent CLI installation, GUI management platforms, provider switching, provider mismatch/proxy/protocol diagnostics, token-saving helpers, and resumable handoff notes for long-running Agent work.

## What it includes

- Base CJK locale/font setup with Noto CJK and WenQuanYi supplemental fonts
- `LANG=en_US.UTF-8` locale strategy without forcing persistent `LC_ALL`
- WSL-specific guidance for distro existence preflight, WSLg, external X Servers, default users, and Windows-to-WSL command quoting
- Optional GUI/AppImage/Electron/Tauri/Playwright runtime libraries
- Optional Node.js, pnpm, Python, terminal-tool, Git/SSH, and WSL workspace setup
- Agent CLI installation guidance for Claude Code, OpenAI Codex CLI, OpenCode, Hermes, OpenClaw, cc-switch-cli, and related tools
- Provider operations for stable user paths, optional `/usr/local/bin` shims for GUI/IDE launchers, PATH, symlinks, non-interactive shells, token-tool alias/hook compatibility, cc-switch provider lifecycle, live config verification, proxy/protocol troubleshooting, and external launcher mismatch debugging
- GUI management platform guidance for Orca, Polaris, TOKENICODE, and CloudCLI/claudecodeui
- Token-saving helper guidance for LeanCTX, Headroom, and RTK, including launcher-safe alias/hook/proxy handling
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

The references are intentionally split for progressive disclosure rather than collapsed into one large manual:

- Environment layers: `base-linux-setup.md`, `wsl-integration.md`, `gui-appimage-runtime.md`, `developer-toolchain.md`.
- Agent layers: `agent-cli-installation.md`, `agent-provider-operations.md`, `agent-gui-management.md`.
- Support layers: `session-continuity.md`, `official-sources.md`.

Keep this split unless a file becomes only a redirect/stub. In particular, do not merge `agent-provider-operations.md` into installer docs; it is large because it preserves field-tested mismatch diagnostics and should load only during provider/launcher troubleshooting.

## Install

Copy the complete `linux-agent-env/` directory into the target Agent's skills directory. Keep `SKILL.md`, `README.md`, `CHANGELOG.md`, `.gitignore`, and the full `references/` directory together.

GitHub latest URL:

```text
https://github.com/MeowLove/CXT-Skills/tree/main/linux-agent-env
```

Stable tagged URL after publishing `v4.0.2`:

```text
https://github.com/MeowLove/CXT-Skills/tree/v4.0.2/linux-agent-env
```

For Codex skill-installer compatible flows, the equivalent parameters are:

```bash
install-skill-from-github.py --repo MeowLove/CXT-Skills --path linux-agent-env --ref main
# or, after tagging:
install-skill-from-github.py --repo MeowLove/CXT-Skills --path linux-agent-env --ref v4.0.2
```

Do not use `https://github.com/MeowLove/CXT-Skills/linux-agent-env`; GitHub web directory links require `/tree/<branch>/<path>`.

## Usage

Tell the Agent to use `linux-agent-env` and state the target, for example: configure a WSL distro, install Agent CLIs, add provider switching, debug provider mismatch, or create resumable handoff notes. The Skill's `SKILL.md` routes the Agent to the required reference file.

## Updating and version checks

There is no universal Skill update marker that every Agent client honors. Keep `metadata.version` in `SKILL.md`, this README marker, Git tags, and `CHANGELOG.md` synchronized. For reproducible installs, install from a tag such as `v4.0.2`; for latest installs, use `main`.

## Safety notes

- Many workflows modify system packages, users, locale, timezone, WSL defaults, shell startup files, or Agent tools. Run them only with explicit authorization.
- Prefer day-to-day Agent work under a normal user such as `agent`, not `root`.
- Do not store API keys, passwords, private SSH keys, tokens, cookies, or full auth files in handoff notes or public logs.
- Re-check upstream official docs before running network installers when internet access is available.

## Release hygiene

Before publishing, include only this skill directory and avoid committing generated state such as `.agent-state/`, backups, logs, caches, `node_modules/`, or build output.

## Release checklist

- `SKILL.md` `metadata.version`, README release marker, tag examples, and `CHANGELOG.md` top entry all match.
- Markdown code fences and local links validate.
- Files are UTF-8 without BOM where possible.
- No generated logs, caches, credentials, auth files, private SSH keys, or API-key material are committed.
- GitHub directory URL uses `/tree/<branch-or-tag>/linux-agent-env`, not `/linux-agent-env`.

Suggested release commands from the repository root:

```bash
git add linux-agent-env
git commit -m "Release linux-agent-env v4.0.2"
git tag v4.0.2
git push
git push origin v4.0.2
```

## Attribution

Original source concept and authorship: CXT, MeowLove - `WWW.CXTHHHHH.COM`.


V4 field note: CXT, with MeowLove, promoted this Skill to the v4 line after repeated real-world deployments and issue discussions with multiple open-source Agent/tool projects. The v4 focus is external GUI/IDE/Agent compatibility: Orca/GUI/service launch environments, user-level versus system-level CLI discovery, and token-saver alias/hook/proxy interactions.

## 更新历史

README only keeps the compact major-version history. See [CHANGELOG.md](CHANGELOG.md) for the fuller release notes.

- **v4.x** - Current major line. Release-hardened Agent environment toolkit shaped by CXT/MeowLove real deployments and upstream issue discussions: version-consistent publishing, official-source recheck notes, launcher-safe token saver guidance, GUI/IDE/service discovery vs runtime-injection separation, and stricter release hygiene.
- **v3.x** - Rebuilt as an engineered Linux/WSL Agent environment toolkit: concise `SKILL.md` router, modular references, official-source rechecks, provider/launcher mismatch playbooks, GUI management guidance, resumable handoff workflow, and stricter official-native installer precedence.
- **v2.x** - Expanded from base locale setup into a practical Agent workstation installer: WSLg/X Server guidance, normal-user policy, developer toolchains, Agent CLI installation, cc-switch app-scoped provider operations, token savers, GitHub install/update/version notes, and real-world WSL/provider troubleshooting.
- **v1.x local versions** - Started as a local Linux/WSL CJK environment setup Skill: install Chinese/CJK language and font support for Debian/Ubuntu and RHEL-family systems, keep an English `en_US.UTF-8` runtime locale, set Singapore/UTC timezone options, and create a least-privilege `agent` user for daily Agent work.
