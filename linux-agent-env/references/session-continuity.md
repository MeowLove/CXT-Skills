# Session Continuity and Handoff Notes

Use this reference for long-running Agent workstation setup, multi-step package installs, codebase setup, GUI/toolchain deployment, or any task likely to exceed the model context window. The goal is not to store the whole conversation; it is to keep a compact, private, resumable state outside the model context.

## Policy

- Create session notes early for long or risky tasks, then update them after each meaningful phase.
- Prefer project-local notes under `.agent-state/` when the work is tied to a repo/project and should survive a new session. Prefer a temp directory when the notes are purely disposable.
- Avoid multi-agent/session collisions: every run must use a unique session directory, not shared flat files like `/work/plan.md` unless the user explicitly asks for that exact path.
- Do not store secrets: no API keys, access tokens, passwords, private SSH keys, cookie values, or full proprietary logs. Redact sensitive command output.
- If writing inside a Git worktree, keep `.agent-state/` out of commits by adding it to `.git/info/exclude` by default. Use `.gitignore` only if the user wants a shared ignore rule committed.
- Update `handoff.md` before context-heavy operations, before risky system changes, before waiting on long installs/builds, and before ending the session.

## Create a Safe State Directory

Project-local, persistent, unique, and excluded from Git commits:

```bash
umask 077
SESSION_PREFIX="${AGENT_SESSION_ID:-$(date -u +%Y%m%dT%H%M%SZ)-${USER:-agent}-$$}"
STATE_ROOT="${AGENT_STATE_ROOT:-$PWD/.agent-state}"
mkdir -p "$STATE_ROOT"
STATE_DIR="$(mktemp -d "$STATE_ROOT/${SESSION_PREFIX}.XXXXXX")"

if git rev-parse --is-inside-work-tree >/dev/null 2>&1; then
  mkdir -p "$(git rev-parse --git-path info)"
  grep -qxF '.agent-state/' "$(git rev-parse --git-path info/exclude)" 2>/dev/null || \
    echo '.agent-state/' >> "$(git rev-parse --git-path info/exclude)"
fi

printf '%s\n' "$STATE_DIR"
```

Temporary, unique, and collision-safe:

```bash
umask 077
STATE_DIR="$(mktemp -d "${TMPDIR:-/tmp}/linux-agent-env-${USER:-agent}-XXXXXX")"
printf '%s\n' "$STATE_DIR"
```

Create the standard files:

```bash
cat > "$STATE_DIR/plan.md" <<'EOF'
# Plan

- Objective:
- Scope:
- Assumptions:
- Steps:
  - [ ] Detect environment
  - [ ] Apply configuration
  - [ ] Verify
  - [ ] Handoff
EOF

cat > "$STATE_DIR/session-notes.md" <<'EOF'
# Session Notes

## Environment

## Decisions

## Commands Run

## Results

## Problems / Fixes
EOF

cat > "$STATE_DIR/handoff.md" <<'EOF'
# Handoff

## Current status

## Completed

## Remaining

## Important paths

## Verification already done

## Next recommended command

## Warnings / do not repeat
EOF
```

## Update Cadence

Update notes at these checkpoints:

- after environment detection (`/etc/os-release`, WSL status, current user, locale, package manager);
- after package installs or tool installers;
- after creating users, changing WSL defaults, changing locale/timezone, or editing shell startup files;
- after configuring Agent CLIs, `cc-switch`, GUI managers, token savers, Git/SSH, or workspace directories;
- when an error is diagnosed and fixed;
- before any long-running install/build/test;
- before the model context feels crowded or before ending the session.

Append a concise checkpoint:

```bash
cat >> "$STATE_DIR/session-notes.md" <<EOF

## $(date -Is) checkpoint

- Done:
- Commands:
- Result:
- Issue/fix:
EOF
```

Refresh handoff with the minimum information a new Agent needs:

```bash
cat > "$STATE_DIR/handoff.md" <<EOF
# Handoff

## Current status

## Completed

## Remaining

## Important paths
- State dir: $STATE_DIR
- Workspace:
- Config files touched:

## Verification already done

## Next recommended command

## Warnings / do not repeat
- Do not rerun completed installers unless version check fails.
- Do not print or store secrets.
EOF
```

## Suggested Handoff Content

Keep `handoff.md` short and factual:

- exact distro/WSL name and user used;
- installed packages/tools and versions;
- files changed (`/etc/locale.conf`, `/etc/default/locale`, `/etc/wsl.conf`, shell rc files, workspace paths);
- Agent CLIs installed and verification commands;
- `cc-switch provider current` result, but not API keys;
- GUI manager URL/port or desktop asset installed;
- token saver installed and bypass/raw-output command;
- unresolved errors with the last safe command to retry.

## Resume in a New Session

Tell the next Agent:

```text
Please continue from the handoff files in <STATE_DIR>. Read handoff.md, plan.md, and session-notes.md first. Do not repeat completed steps unless verification fails.
```

New session bootstrap:

```bash
STATE_DIR="<paste-state-dir>"
sed -n '1,220p' "$STATE_DIR/handoff.md"
sed -n '1,220p' "$STATE_DIR/plan.md"
sed -n '1,260p' "$STATE_DIR/session-notes.md"
```

Then verify the current system state instead of trusting notes blindly:

```bash
whoami
cat /etc/os-release 2>/dev/null || true
locale 2>/dev/null || true
command -v claude codex opencode hermes openclaw cc-switch cloudcli 2>/dev/null || true
```

## Cleanup

Keep successful project-local notes until the user confirms no more handoff is needed. For temporary notes:

```bash
# Only after the user confirms the state is no longer needed:
rm -rf "$STATE_DIR"
```

Never run cleanup against an unset or suspicious path:

```bash
[ -n "${STATE_DIR:-}" ] && [ -d "$STATE_DIR" ] && printf 'Would remove: %s\n' "$STATE_DIR"
```
