# linux-agent-env ????

This file keeps fuller release notes so `README.md` can stay concise.

## v4.0.2 - Reference consolidation review and v4 provenance note
- Bumped the publish version marker from `4.0.1` to `4.0.2`.
- Reviewed the `references/` directory for possible merges. Kept the current split because it supports progressive disclosure: environment layers, Agent layers, and support/audit files load only when needed.
- Added a v4 field-origin note: CXT/MeowLove upgraded the Skill to v4 after real deployments and issue discussions with multiple open-source Agent/tool projects, focusing on external GUI/IDE/Agent launcher compatibility.
- Reconfirmed the v4 compatibility model: verify the real launcher environment, separate canonical CLI discovery from token-tool runtime injection, and avoid reinstalling CLIs as root/package-manager fallbacks just because a GUI cannot find user-level commands.
- Refreshed README release/tag examples to `v4.0.2` and documented why `agent-provider-operations.md` remains a separate large field-notes file.

# linux-agent-env 更新历史

This file keeps fuller release notes so `README.md` can stay concise.

## v4.0.1 - Release hardening and official-source recheck
- Bumped the publish version marker from `3.2.1` to `4.0.1`.
- Re-checked the Skill against current official-source strategy on 2026-07-09 and refreshed release references.
- Promoted launcher-safe token saver behavior into the v4 release line: keep canonical Agent CLI discovery separate from LeanCTX/Headroom/RTK runtime injection.
- Added README release checklist for version consistency, Markdown/link validation, UTF-8/no-BOM hygiene, and generated-state exclusion before publishing.
- Kept the official-native installer precedence: use each tool's recommended/native install script first; npm/pip/apt/dnf/manual archives remain explicit fallback paths.


## v3.2.1 - Installer precedence hardening and README simplification
- Added token-saver launcher compatibility guidance: separate executable discovery from LeanCTX/Headroom/RTK runtime injection, prefer clean canonical Agent names for unknown launchers, and document `--no-agent-aliases`, `BASH_ENV`, `type -P`, and hook audits.

- Bumped the publish version marker from `3.1.0` to `3.2.1`.
- Hardened Agent CLI installation policy: known Linux/WSL Agent CLIs must prefer official recommended/native/quickstart install scripts before npm, OS package managers, Homebrew, manual GitHub release archives, or source builds.
- Clarified that Node.js/npm workstation setup does not authorize replacing an Agent tool's recommended native installer with npm.
- Simplified README Install and Usage sections so users/Agents only need the complete `linux-agent-env/` directory or the GitHub tree/tag URL.
- Added system-level CLI shim guidance for Orca/GUI/IDE/service launchers that cannot see user-level `~/.local/bin` installs.

## v3.1.0 - Release documentation polish

- Bumped the publish version marker from `3.0.2` to `3.1.0`.
- Moved compact release history to the end of `README.md` so installation, usage, safety, and release instructions stay prominent.
- Added this `CHANGELOG.md` for fuller release notes, including the original v1 local-version history.

## v3.0.2 - Official documentation re-check

- Removed the temporary v2 compatibility redirect files after verifying active references now point to `references/agent-provider-operations.md`.
- Re-checked Agent CLI and GUI management install guidance against current official sources on 2026-07-08.
- Historical note: Claude Code install guidance was audited in this release; the current effective v4.0.2 policy remains: prefer the official recommended/native installer script when available and do not fall back to npm/apt/dnf/apk unless explicitly justified.
- Kept Codex guidance dual-path: OpenAI/openai-codex GitHub documents the standalone macOS/Linux installer, while OpenAI Help/Developer docs still emphasize npm; the Skill calls out both as official and warns to keep install method consistent.
- Confirmed cc-switch app-scoped commands, supported app IDs, and default `~/.local/bin` install behavior from SaladDay/cc-switch-cli.
- Confirmed CloudCLI Node.js v22+ / `npx @cloudcli-ai/cloudcli`, Orca release/download guidance, Polaris `package:web` flow and requirements, and TOKENICODE Linux package/WebKitGTK notes.

## v3.0.1 - Architecture refactor

- Reorganized the Skill as an engineered, layered toolkit: concise `SKILL.md` router plus task-specific references.
- Moved base locale/font/time/user commands into `references/base-linux-setup.md`.
- Merged provider path, cc-switch, proxy, protocol, live-config, GUI/IDE/service launcher, and PowerShell-to-WSL mismatch field notes into `references/agent-provider-operations.md`.
- Clarified the complete execution pipeline: session continuity, base setup, WSL/GUI, least-privilege user, developer toolchain, Agent CLI, provider switching, real launcher verification, token saver, final handoff.

## v2.5.1 - WSL/provider field-notes hardening

- Aligned the release marker and tagged install examples to `v2.5.1`.
- Kept `cc-switch-cli` examples app-scoped by default with `cc-switch --app <app> provider ...`.
- Added WSL distribution existence preflight guidance to prevent repeated same-name create/import attempts when Agent sandbox output is empty, garbled, or inconsistent with the user's interactive PowerShell session.
- Added a detailed real-world provider mismatch playbook for cases where `cc-switch` looks correct but GUI/IDE/service/Windows-to-WSL launchers still use the wrong account, endpoint, model, protocol, proxy, user, config directory, or produce empty output/logs.

## v2.x - Agent workstation expansion

- Renamed and repositioned the Skill from a CJK/locale setup helper into `linux-agent-env`.
- Added WSL-specific guidance: distro existence checks, Windows-to-WSL command patterns, default-user behavior, WSLg vs external X Server routing, and GUI rendering troubleshooting.
- Added optional GUI/AppImage/Electron/Tauri/Playwright runtime guidance for minimal Linux installations.
- Added developer workstation layers: Node.js LTS/npm/corepack/pnpm, Python CLI helpers, terminal tools, Git/SSH identity, and WSL ext4 workspace directories.
- Added Agent CLI installation guidance for Claude Code, OpenAI Codex CLI, OpenCode, Hermes, OpenClaw, cc-switch-cli, LeanCTX, Headroom, RTK, and related tools.
- Added cc-switch provider lifecycle commands, app-scoped provider operations, and post-install recommendations to configure providers/subscriptions.
- Added GitHub install/update notes, tree URL guidance, release tag examples, and version-marker conventions.

## v1.x local versions - Original Linux/WSL CJK locale setup

The earliest local versions focused on making Linux/WSL usable for Chinese filenames, terminal output, and GUI font rendering while keeping the runtime environment broadly compatible for Agent tools.

Core functionality:

- Installed Chinese/CJK language and font support for Debian/Ubuntu and RHEL-family systems.
- Used Noto CJK as the main cross-distribution CJK font family, later supplemented by WenQuanYi fonts.
- Generated and selected `en_US.UTF-8` as the persistent runtime locale so English CLI tools remain stable while Chinese filenames and text render correctly.
- Avoided relying on bare `C.UTF-8` for Chinese-heavy environments when full locale data was available.
- Provided timezone options such as `Asia/Singapore` and `UTC`, plus later notes for Windows/Linux dual-boot RTC behavior.
- Created a normal `agent` user for day-to-day Agent work and discouraged running Agent CLIs as `root` unless required.
- Included basic verification commands such as `locale`, `date`, user checks, and CJK filename/font tests.
