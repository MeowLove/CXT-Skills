# Agent Provider Operations and Mismatch Troubleshooting

Use this reference after Agent CLI installation and whenever provider, account, proxy, PATH, HOME, config home, GUI launcher, IDE, service, CI, or Windows-to-WSL behavior is inconsistent.

This v4 provider operations file merges and organizes the previous stable-path and provider-mismatch field notes. It intentionally keeps the field-tested command blocks because these paths are fragile and have caused real deployment failures.


V4 field origin: this file preserves real deployment troubleshooting patterns collected by CXT/MeowLove while coordinating issue reports and compatibility discussions with multiple Agent/tool projects. The central lesson is that successful CLI installation is not enough: external GUI/IDE/service/WSL launchers must discover the same executable, user, HOME, PATH, provider config, and token-saver runtime injection path that the real Agent session uses.

## v4 Decision Tree

```text
CLI missing or wrong version?
  -> Part A: stable user paths, PATH, symlinks, install resolution.

cc-switch has no provider/current provider?
  -> Part A: app-scoped provider list/add/switch.

cc-switch current looks right but Agent uses wrong endpoint/account/model/key?
  -> Part B: real launcher, live config, protocol, proxy, stale session.

Direct terminal works but GUI/IDE/service/Windows-to-WSL fails?
  -> Part B: diagnose inside that launcher environment, not a separate shell.

Config points to localhost but calls fail?
  -> Part B: check proxy process and listening port.

PowerShell -> WSL returns empty output or syntax errors?
  -> Part B: named script variables, script length checks, CRLF stripping, WSL-side logs.
```

## v4 Rules to Apply First

1. Install and run Agent CLIs as the normal `agent` user unless the user explicitly chooses another user.
2. Prefer stable user-level entrypoints: `~/.local/bin/<tool>`.
3. Use app-scoped cc-switch commands: `cc-switch --app <app> provider ...`.
4. Do not trust `cc-switch provider current` alone; inspect live config and run a real minimal request.
5. If a GUI/IDE/service/Windows-to-WSL launcher starts the Agent, verify from that exact launcher environment.
6. Any localhost provider/proxy config requires a running process and listening port.
7. Restart stale launcher sessions after provider/env changes.
8. Redact API keys, tokens, cookies, passwords, private keys, and full auth files from logs.

---

## Part A — Stable Agent CLI Operations

Use this reference after installing Agent CLIs or when an external Agent cannot find `claude`, `codex`, `cc-switch`, or cannot apply provider settings reliably. These notes are based on real deployment pitfalls: user/root split, non-interactive PATH, broken symlinks, mixed install methods, and cc-switch/Codex provider edge cases. If `cc-switch` appears correct but the real GUI/IDE/service/Windows-to-WSL launched Agent still uses the wrong account, endpoint, model, protocol, proxy, user, config directory, or returns empty output/logs, continue with the provider mismatch sections in this file.

## Short Principles

1. **Fixed normal user**: install and run Agent CLIs as the normal `agent` user; do not mix root and user config.
2. **Fixed entry path**: prefer `~/.local/bin/<tool>` as the stable user-level entrypoint.
3. **System-visible shim when needed**: if GUI/IDE/service launchers cannot see the user PATH, link `/usr/local/bin/<tool>` to `/home/agent/.local/bin/<tool>` after verifying the user-level entrypoint. Treat this as an optional compatibility shim, not the primary install location.
4. **Fixed PATH**: ensure `~/.local/bin` is in PATH; automation should explicitly set PATH.
5. **Verify resolution**: use `type -a`, `command -v`, `readlink -f`, and `--version`.
6. **Avoid mixed installs**: do not let apt/npm/standalone/root/user installs shadow each other silently.
7. **Per-app provider configs**: Claude, Codex, Gemini, OpenCode, Hermes, OpenClaw, etc. should have separate provider entries.
8. **Prefer native protocol**: use direct native API configuration when upstream already supports the target app protocol; use cc-switch proxy/adapter only for conversion or takeover.
9. **Local proxy must persist**: any config pointing to `127.0.0.1`/`localhost` requires a running process and a listening port.
10. **Codex custom Responses provider must be explicit**: set `wire_api = "responses"` and `requires_openai_auth = false` for third-party API-key providers unless current Codex docs/provider docs say otherwise.
11. **Do not rely on implicit field-mode generation for Codex**: use `--config-file` with raw config when field-mode output is wrong or ambiguous.
12. **cc-switch database is source-of-truth**: do not only edit live config; provider switch can overwrite live files.
13. **Real launcher wins**: provider success must be verified from the same GUI/IDE/service/Windows-to-WSL launcher environment that will run the Agent, not only from a separate terminal.

## User and Config Directory Split

Root and normal users have different command and config locations:

```text
/root/.local/bin
/root/.claude
/root/.codex
/root/.cc-switch

/home/agent/.local/bin
/home/agent/.claude
/home/agent/.codex
/home/agent/.cc-switch
```

Mixing them causes external Agents to miss commands or read the wrong config. Verify before installing or debugging:

```bash
whoami
echo "$HOME"
```

Expected for day-to-day Agent work:

```text
agent
/home/agent
```

## WSL Default User and Optional systemd

Set the default WSL user to the normal user after it exists:

```ini
[user]
default=agent
```

If a persistent user service is needed, for example a long-running `cc-switch proxy`, enable systemd only when appropriate:

```ini
[boot]
systemd=true
```

Restart and verify from Windows:

```powershell
wsl --terminate <DistroName>
# or: wsl --shutdown
wsl -d <DistroName> -- whoami
```

Expected output:

```text
agent
```

## Stable User-Level Entrypoints

Prefer stable user-level command paths:

```text
/home/agent/.local/bin/claude
/home/agent/.local/bin/codex
/home/agent/.local/bin/cc-switch
```

Avoid letting active commands scatter unpredictably across:

```text
/usr/bin
/usr/local/bin
/root/.local/bin
/home/agent/.npm-global/bin
```

Ensure user shell startup files include `~/.local/bin` once:

```bash
grep -n '.local/bin' ~/.profile ~/.bashrc 2>/dev/null || true

grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.profile 2>/dev/null || \
  printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> ~/.profile

grep -qxF 'export PATH="$HOME/.local/bin:$PATH"' ~/.bashrc 2>/dev/null || \
  printf '\nexport PATH="$HOME/.local/bin:$PATH"\n' >> ~/.bashrc
```

Automation, CI, systemd, and external Agents often run non-interactive non-login shells and may not load `~/.profile` or `~/.bashrc`. In automation, set PATH explicitly or use absolute paths:

```bash
export PATH="$HOME/.local/bin:/usr/local/bin:/usr/bin:/bin:$PATH"

/home/agent/.local/bin/claude --version
/home/agent/.local/bin/codex --version
/home/agent/.local/bin/cc-switch --version
```

## System-Level Agent CLI Shims for GUI/IDE Launchers

Create system-level shims only when a real launcher cannot resolve user-installed CLIs. Examples include Orca desktop, Tauri/Electron AppImages, IDE plugins, systemd services, Windows-to-WSL wrappers, or non-interactive shells that do not load `/home/agent/.profile` or `/home/agent/.bashrc`.

Purpose:

- User-level install remains the source of truth under `/home/agent/.local/bin` and the user's config remains under `/home/agent`.
- `/usr/local/bin/<tool>` acts as a stable, system-visible command name for launchers whose PATH is closer to `/usr/local/bin:/usr/bin:/bin`.
- GUI managers such as Orca may start terminal agents from their own environment; if they cannot see `claude`, `codex`, `cc-switch`, or token helpers, this shim is often safer than reinstalling the tools as root or via apt/npm.

Risks and multi-user rules:

- `/usr/local/bin/<tool>` is global. On a multi-user host it can point only to one user's chosen CLI, so it may route other users to `agent`'s binaries and config expectations.
- Do not create global shims on shared hosts unless the machine is intentionally an `agent` workstation, users agree on the default CLI owner, or the launcher is explicitly configured to run as `agent`.
- If multiple users need independent Agent accounts, prefer per-user PATH fixes, per-launcher command overrides using absolute paths, or wrapper scripts with distinct names such as `/usr/local/bin/claude-agent` instead of replacing `/usr/local/bin/claude`.
- Creating or changing `/usr/local/bin` entries requires root/sudo. Never point a global shim at `/root/.local/bin` or a temporary cache path.

Preflight before creating global shims:

```bash
# Run as the normal agent user first.
whoami
echo "$HOME"
for t in claude codex cc-switch leanctx headroom rtk; do
  if [ -e "$HOME/.local/bin/$t" ]; then
    printf '%s -> ' "$HOME/.local/bin/$t"
    readlink -f "$HOME/.local/bin/$t" || true
    test -x "$(readlink -f "$HOME/.local/bin/$t")" && echo "ok: $t" || echo "not executable: $t"
  fi
done
```

Create only shims for tools that actually exist:

```bash
# Replace /home/agent if the configured normal user is different.
for t in claude codex cc-switch leanctx headroom rtk opencode hermes openclaw gemini cloudcli; do
  if [ -x "/home/agent/.local/bin/$t" ] || [ -L "/home/agent/.local/bin/$t" ]; then
    sudo ln -sfn "/home/agent/.local/bin/$t" "/usr/local/bin/$t"
  fi
done
```

Verify from the same environment that launches the GUI/IDE/service, not only from an interactive terminal:

```bash
type -a claude codex cc-switch 2>/dev/null || true
command -v claude codex cc-switch 2>/dev/null || true
readlink -f /usr/local/bin/claude /usr/local/bin/codex /usr/local/bin/cc-switch 2>/dev/null || true
/usr/local/bin/claude --version 2>/dev/null || true
/usr/local/bin/codex --version 2>/dev/null || true
/usr/local/bin/cc-switch --version 2>/dev/null || true
```

Rollback only the shims you created:

```bash
sudo rm -f /usr/local/bin/claude /usr/local/bin/codex /usr/local/bin/cc-switch \
  /usr/local/bin/leanctx /usr/local/bin/headroom /usr/local/bin/rtk \
  /usr/local/bin/opencode /usr/local/bin/hermes /usr/local/bin/openclaw \
  /usr/local/bin/gemini /usr/local/bin/cloudcli
```

## Token Saver and External Launcher Compatibility

Use this section when LeanCTX, Headroom, RTK, or another token/context tool is installed together with Orca, a GUI manager, IDE plugin, SSH launcher, Windows-to-WSL wrapper, CI/service, or any non-interactive shell.

Core rule: **separate discovery from launch/runtime injection**.

- Discovery must resolve the canonical Agent executable path, such as `claude`, `codex`, `opencode`, `hermes`, or `openclaw`.
- Runtime injection may add token-saving hooks, wrappers, proxy variables, MCP/tools, or shell startup files.
- Do not let aliases/functions/wrappers hide the real Agent executable from external launchers unless the launcher is confirmed to resolve past them.

### Common Integration Patterns

LeanCTX may install Agent aliases similar to:

```bash
alias claude='LEAN_CTX_AGENT=1 BASH_ENV="$HOME/.bashenv" claude'
alias codex='LEAN_CTX_AGENT=1 BASH_ENV="$HOME/.bashenv" codex'
```

These aliases are useful in interactive shells because `LEAN_CTX_AGENT=1` marks the Agent session and `BASH_ENV="$HOME/.bashenv"` makes non-interactive Bash load LeanCTX hooks. The risk is that some discovery code uses `command -v claude` and receives alias text instead of an executable path.

Default decision:

```bash
# Confirm the installed version supports the desired flags before relying on them.
lean-ctx onboard --help 2>/dev/null | grep -E 'no-agent-aliases|agent-alias' || true
lean-ctx config --help 2>/dev/null || true

# Known alias-aware launcher, fixed Orca, or human terminal only:
lean-ctx onboard

# Unknown launcher, older launcher, or discovery failure, when supported:
lean-ctx onboard --no-agent-aliases
# or persist the preference first, if supported by the installed LeanCTX version:
lean-ctx config set skip_agent_aliases true
lean-ctx onboard
```

`--no-agent-aliases` / `skip_agent_aliases` should not be treated as disabling LeanCTX. MCP/tools, PreToolUse-style hooks, `.bashenv` / `.zshenv` infrastructure, config, doctor/status/gain commands, and explicit LeanCTX commands may still remain available. It mainly avoids shadowing canonical `claude`/`codex` names and therefore improves launcher discovery.

RTK usually uses hook/plugin/rules integration and explicit `rtk ...` command wrappers rather than aliasing `claude` or `codex` directly. It is less likely to break binary discovery by aliases, but it can still collide with shell hooks, plugin rules, project instructions, or command interception.

Headroom commonly uses explicit wrapper/proxy patterns such as:

```bash
headroom wrap claude
headroom wrap codex
ANTHROPIC_BASE_URL=http://localhost:8787 claude
```

A launcher may discover the native `claude` binary successfully while not actually starting it through Headroom. Verify both discovery and runtime optimization.

### Restore Runtime Injection Without Breaking Discovery

Prefer these non-shadowing paths when aliases/functions break a launcher:

1. **Launcher-specific environment or command** when the launcher supports it:

   ```bash
   env LEAN_CTX_AGENT=1 BASH_ENV=/home/agent/.bashenv /usr/local/bin/claude
   env LEAN_CTX_AGENT=1 BASH_ENV=/home/agent/.bashenv /usr/local/bin/codex
   ```

2. **Non-conflicting manual aliases** for human terminal use only:

   ```bash
   alias claude-lctx='LEAN_CTX_AGENT=1 BASH_ENV="$HOME/.bashenv" /home/agent/.local/bin/claude'
   alias codex-lctx='LEAN_CTX_AGENT=1 BASH_ENV="$HOME/.bashenv" /home/agent/.local/bin/codex'
   ```

   Keep `claude` and `codex` discoverable; use `claude-lctx` / `codex-lctx` manually when desired.

3. **Stable user or system shims** for launchers whose PATH cannot see `~/.local/bin`. Use the audited shim policy above and point `/usr/local/bin/<tool>` back to `/home/agent/.local/bin/<tool>`. Do not reinstall the Agent CLI as root only to satisfy discovery.

### Avoid Global BASH_ENV by Default

Do not globally export `BASH_ENV` in `/etc/environment`, `/etc/profile`, or broad service environments by default. `BASH_ENV` affects non-interactive Bash and can change builds, package managers, CI jobs, scripts, and services. Prefer per-launcher `env BASH_ENV=... <command>` when full LeanCTX runtime injection is required.

LeanCTX settings such as:

```bash
lean-ctx config set shell_activation always
```

may make hooks more broadly active after they are loaded, but they do not by themselves guarantee that non-interactive Bash loads `~/.bashenv`; the relevant process still needs `BASH_ENV` or another documented startup path. Test carefully with project scripts and `lean-ctx doctor`.

### Robust Discovery Checks

Run these checks in the **same environment that launches the Agent**. Do not rely on a separate interactive shell.

```bash
whoami
echo "HOME=$HOME"
echo "PATH=$PATH"

type -a claude codex cc-switch lean-ctx headroom rtk 2>/dev/null || true
for t in claude codex cc-switch lean-ctx headroom rtk; do
  echo "== $t =="
  type -t "$t" 2>/dev/null || true
  type -P "$t" 2>/dev/null || type -p "$t" 2>/dev/null || true
  command -v "$t" 2>/dev/null || true
  alias "$t" 2>/dev/null || true
  declare -f "$t" 2>/dev/null | sed -n '1,12p' || true
  p="$(type -P "$t" 2>/dev/null || type -p "$t" 2>/dev/null || command -v "$t" 2>/dev/null || true)"
  [ -n "$p" ] && readlink -f "$p" 2>/dev/null || true
  "$t" --version 2>/dev/null || "$t" version 2>/dev/null || true
done

env | sort | grep -Ei 'LEAN|BASH_ENV|HEADROOM|RTK|CLAUDE|CODEX|ANTHROPIC|OPENAI|BASE|PROXY|TOKEN|KEY|HOME|PATH' || true
```

Interpretation:

- If `command -v claude` prints `alias claude=...`, a launcher that expects a path may fail.
- If `type -P claude` or `type -p claude` returns a real file, an alias-aware launcher should prefer that over alias text.
- If `/usr/local/bin/claude` points to `/home/agent/.local/bin/claude`, verify the target user and config are correct before assuming provider settings are wrong.
- If Headroom/RTK/LeanCTX status is clean but the GUI-launched Agent does not show savings, the launcher may be bypassing runtime injection even though discovery is correct.

### Hook and Wrapper Audit

When behavior is still inconsistent, audit shell and Agent hook locations without dumping secrets:

```bash
alias | grep -Ei 'claude|codex|lean|headroom|rtk' || true
for f in ~/.bashrc ~/.profile ~/.bash_profile ~/.bashenv ~/.zshrc ~/.zshenv; do
  [ -f "$f" ] && grep -nEi 'lean|headroom|rtk|BASH_ENV|claude|codex' "$f" || true
done
find ~/.claude ~/.codex ~/.config -maxdepth 5 -type f 2>/dev/null | grep -Ei 'settings|hook|mcp|lean|headroom|rtk|provider|config' || true
lean-ctx status 2>/dev/null || true
lean-ctx doctor 2>/dev/null || true
headroom --help >/dev/null 2>&1 && headroom mcp status 2>/dev/null || true
rtk gain 2>/dev/null || true
```

Decision tree:

```text
Launcher is known alias-aware and can launch successfully:
  Use the token tool's normal integration, e.g. lean-ctx onboard.

Launcher discovery fails or command path becomes alias/function text:
  Keep canonical names clean, e.g. lean-ctx onboard --no-agent-aliases.
  Add launcher env command, non-conflicting aliases, or audited shims as needed.

Discovery succeeds but token savings are absent:
  Check whether launcher starts the native CLI directly and bypasses wrappers/proxy/env.
  Configure launcher command/env or use the token tool's documented wrapper/proxy path.

Multiple token savers are installed:
  Disable all but the selected one for the test. Do not debug stacked hooks first.
```

## Locate Real Installations Before Symlinking

If a command is missing or `~/.local/bin/<tool>` is absent, do not create a blind symlink. Locate the real binary first:

```bash
command -v claude codex cc-switch 2>/dev/null || true
ls -l ~/.local/bin/claude ~/.local/bin/codex ~/.local/bin/cc-switch 2>/dev/null || true

find "$HOME" /usr/local/bin /usr/bin -maxdepth 6 \( -type f -o -type l \) \
  \( -name claude -o -name codex -o -name cc-switch \) 2>/dev/null
```

Verify the found file:

```bash
/path/to/tool --version
```

Then create user-level symlinks:

```bash
mkdir -p "$HOME/.local/bin"
ln -sf /real/path/to/claude "$HOME/.local/bin/claude"
ln -sf /real/path/to/codex "$HOME/.local/bin/codex"
ln -sf /real/path/to/cc-switch "$HOME/.local/bin/cc-switch"
```

Optional global fallback shims for external tools that do not use the user's PATH. Use this after the full system-level shim preflight above, especially for Orca/GUI/IDE launchers:

```bash
sudo ln -sf /home/agent/.local/bin/claude /usr/local/bin/claude
sudo ln -sf /home/agent/.local/bin/codex /usr/local/bin/codex
sudo ln -sf /home/agent/.local/bin/cc-switch /usr/local/bin/cc-switch
```

Keep the chain clear:

```text
/usr/local/bin/<tool>
  -> /home/agent/.local/bin/<tool>
      -> real installed binary
```

Do not link `/usr/local/bin/<tool>` directly to temporary cache/version directories unless there is no stable user-level entrypoint.

## Symlink and Resolution Checks

After creating or repairing symlinks:

```bash
readlink -f ~/.local/bin/claude 2>/dev/null || true
readlink -f ~/.local/bin/codex 2>/dev/null || true
readlink -f ~/.local/bin/cc-switch 2>/dev/null || true

test -x "$(readlink -f ~/.local/bin/claude 2>/dev/null)" && echo "claude ok" || true
test -x "$(readlink -f ~/.local/bin/codex 2>/dev/null)" && echo "codex ok" || true
test -x "$(readlink -f ~/.local/bin/cc-switch 2>/dev/null)" && echo "cc-switch ok" || true

type -a claude || true
type -a codex || true
type -a cc-switch || true

command -v claude codex cc-switch 2>/dev/null || true
claude --version 2>/dev/null || true
codex --version 2>/dev/null || true
cc-switch --version 2>/dev/null || true
```

If a symlink is broken, remove only that symlink and re-locate the real install:

```bash
rm -f ~/.local/bin/claude ~/.local/bin/codex ~/.local/bin/cc-switch
```

For Claude Code, if user-level entrypoints are broken and Claude reports that the command is missing or should be repaired, run the repair under the normal user:

```bash
claude install

type -a claude
claude --version
ls -l ~/.local/bin/claude
```

## Avoid Global Shell API Keys

Do not persist API keys in global shell files by default:

```text
~/.bashrc
~/.profile
/etc/environment
```

Avoid long-lived exports such as:

```bash
export OPENAI_API_KEY=...
export ANTHROPIC_AUTH_TOKEN=...
```

Reasons:

- can contaminate multiple Agent tools;
- can override cc-switch or tool-specific configs;
- can confuse provider switching;
- can leak through external Agent logs.

Prefer tool-specific config files or cc-switch provider storage:

```text
~/.codex/auth.json
~/.codex/config.toml
~/.claude/settings.json
~/.cc-switch/cc-switch.db
```

Tighten permissions on sensitive config files:

```bash
chmod 600 ~/.codex/auth.json 2>/dev/null || true
chmod 600 ~/.codex/config.toml 2>/dev/null || true
chmod 600 ~/.claude/settings.json 2>/dev/null || true
chmod 600 ~/.cc-switch/cc-switch.db 2>/dev/null || true
```

Do not write real API keys into Skill docs, README files, shell history, handoff notes, or logs.

## Final Agent CLI Install Verification

Run after install or repair:

```bash
whoami
echo "$HOME"
echo "$PATH"

type -a claude || true
type -a codex || true
type -a cc-switch || true

claude --version 2>/dev/null || true
codex --version 2>/dev/null || true
cc-switch --version 2>/dev/null || true

ls -l ~/.local/bin/claude ~/.local/bin/codex ~/.local/bin/cc-switch 2>/dev/null || true
ls -l /usr/local/bin/claude /usr/local/bin/codex /usr/local/bin/cc-switch 2>/dev/null || true
```

## CC-Switch Provider Checklist

Do not assume one provider works for every application. Check per-app provider state.
Current upstream examples generally use the global app selector form `cc-switch --app <app> provider ...`. Some versions may also accept trailing `--app`, but automation should prefer the upstream/global form for consistency.

```bash
cc-switch --app claude provider list 2>/dev/null || true
cc-switch --app codex provider list 2>/dev/null || true
cc-switch --app gemini provider list 2>/dev/null || true
cc-switch --app opencode provider list 2>/dev/null || true
cc-switch --app hermes provider list 2>/dev/null || true
cc-switch --app openclaw provider list 2>/dev/null || true
```

Also check whether global shell environment variables are overriding the intended app/provider config:

```bash
cc-switch env tools 2>/dev/null || true
cc-switch env check --app claude 2>/dev/null || true
cc-switch env check --app codex 2>/dev/null || true
cc-switch env list --app claude 2>/dev/null || true
cc-switch env list --app codex 2>/dev/null || true
```

Choose each app's native or closest-native protocol first:

| App | Preferred protocol |
|---|---|
| Claude Code | Anthropic Messages / Anthropic-compatible |
| Codex | OpenAI Responses API |
| Gemini | Gemini native API |
| OpenAI-compatible Chat tools | OpenAI Chat Completions API |

Use cc-switch proxy/takeover only for protocol conversion, local takeover, model mapping, or auth adaptation. If upstream already exposes the target app's native-compatible protocol, prefer direct config.

Claude takeover example when upstream is not Anthropic-compatible:

```bash
cc-switch proxy serve --takeover claude --listen-address 127.0.0.1
```

If an Agent config points to a local proxy, verify the proxy is running:

```bash
ss -ltnp | grep -E '127.0.0.1|localhost|cc-switch|15721' || true
ps -ef | grep cc-switch | grep -v grep || true
systemctl --user status <proxy-service-name> 2>/dev/null || true
```

If systemd user services are unavailable, use an explicit user-approved startup method, such as login script, supervisor, tmux, or a temporary foreground command. For ad-hoc backgrounding:

```bash
nohup cc-switch proxy serve ... >/tmp/cc-switch-proxy.log 2>&1 &
```

## Check Live Config After Provider Switch

Do not trust only `cc-switch --app <app> provider list`. After switching, inspect the app's live config:

```bash
# Claude
cat ~/.claude/settings.json 2>/dev/null || true

# Codex
cat ~/.codex/config.toml 2>/dev/null || true
test -f ~/.codex/auth.json && echo "~/.codex/auth.json exists"
```

The provider database is usually the source configuration:

```text
~/.cc-switch/cc-switch.db
```

Manual live-config edits can be overwritten by the next provider switch. Correct workflow:

1. modify or recreate the cc-switch provider source entry;
2. run `cc-switch --app <app> provider switch <provider-id>`;
3. inspect the live config written to the target app.

## Codex Custom Responses Provider

For third-party OpenAI-compatible Responses providers, Codex config should explicitly include:

```toml
wire_api = "responses"
requires_openai_auth = false
```

If generated as `requires_openai_auth = true`, Codex may continue using the OpenAI official auth path and ignore the intended third-party API-key flow.

For Codex, do not rely solely on cc-switch field-mode generation when it creates incorrect auth fields:

```bash
cc-switch --app codex provider add \
  --base-url "$BASE_URL" \
  --api-key "$API_KEY" \
  --model "$MODEL" \
  --api-format responses
```

Prefer full raw config when field-mode is ambiguous:

```json
{
  "auth": {
    "OPENAI_API_KEY": "YOUR_API_KEY"
  },
  "config": "model_provider = \"custom\"\nmodel = \"gpt-5.5\"\nmodel_reasoning_effort = \"high\"\n\n[model_providers.custom]\nname = \"Custom OpenAI Responses\"\nbase_url = \"https://YOUR_API_BASE_URL\"\nwire_api = \"responses\"\nrequires_openai_auth = false\n\n[features]\nhooks = true\n"
}
```

Save it outside logs/history when possible, then add and switch:

```bash
cc-switch --app codex provider add \
  --id custom-codex-responses \
  --name "Custom Codex Responses" \
  --config-file /tmp/codex-provider.json \
  --api-format responses

cc-switch --app codex provider switch custom-codex-responses
```

Verify:

```bash
grep -n "requires_openai_auth" ~/.codex/config.toml 2>/dev/null || true
grep -n "base_url\|wire_api\|model_provider\|model =" ~/.codex/config.toml 2>/dev/null || true
test -f ~/.codex/auth.json && echo "~/.codex/auth.json exists"
```

## Claude Provider Direct vs Proxy

When upstream is Claude/Anthropic-compatible, prefer direct Claude configuration and verify current settings:

```bash
cat ~/.claude/settings.json 2>/dev/null || true
```

Look for the expected provider endpoint, for example:

```json
"ANTHROPIC_BASE_URL": "https://YOUR_ANTHROPIC_COMPATIBLE_BASE_URL"
```

When upstream is not Claude-native, use cc-switch proxy/takeover only if needed and verify the local listener:

```bash
cc-switch proxy serve --takeover claude --listen-address 127.0.0.1
ss -ltnp | grep 15721 || true
```

## Use `common-config` Carefully

`cc-switch` common config can reduce repetition, but implicit merges can also bring old config, MCP entries, hooks, default auth, stale model settings, or provider-specific fields into a target app.

For Codex and other auth-sensitive tools, prefer a complete raw config when provider behavior must be deterministic:

- explicitly set `requires_openai_auth = false` for third-party API-key flows;
- explicitly set `wire_api`, such as `wire_api = "responses"`;
- include hooks/MCP fields explicitly when needed;
- do not rely on implicit common-config auto-merge for critical provider switching;
- after switching, inspect the target live config.

If common config is used, treat the cc-switch provider database as the source of truth and verify the generated live config after every provider switch.

## Avoid TUI in Automation

External Agents and CI usually do not have a TTY. Do not run the interactive TUI in automation:

```bash
cc-switch
```

Use non-interactive commands where the upstream CLI supports them:

```bash
cc-switch --app <app> provider add ...
cc-switch --app <app> provider switch ...
cc-switch --app <app> provider list ...
cc-switch --app <app> provider current ...
```

For edit/delete operations that require confirmation, avoid automation unless the CLI exposes explicit non-interactive flags and the user approved the change.

## Final CC-Switch Verification

```bash
cc-switch --version
cc-switch env tools

cc-switch --app claude provider list 2>/dev/null || true
cc-switch --app codex provider list 2>/dev/null || true

cc-switch --app claude provider current 2>/dev/null || true
cc-switch --app codex provider current 2>/dev/null || true

cc-switch env check --app claude 2>/dev/null || true
cc-switch env check --app codex 2>/dev/null || true

cat ~/.claude/settings.json 2>/dev/null || true
cat ~/.codex/config.toml 2>/dev/null || true
test -f ~/.codex/auth.json && echo "~/.codex/auth.json exists"

grep -n "requires_openai_auth" ~/.codex/config.toml 2>/dev/null || true

ps -ef | grep cc-switch | grep -v grep || true
ss -ltnp | grep -E '15721|cc-switch' || true
```


---

## Part B — Provider Mismatch Field Playbook

Use this skill when an Agent CLI works in one shell but fails, silently exits, returns no visible output, or uses the wrong provider when started by an external launcher, GUI app, IDE, Windows-to-WSL command, background service, or automation.

Typical symptom:

```text
cc-switch current = custom provider
live config looks correct
doctor/check may pass
but real execution still uses:
- official OpenAI / Claude endpoint
- old account
- old API key
- old model
- wrong provider
- wrong proxy
- wrong protocol
- wrong user or HOME
- no visible output
- empty log with exit code 0
```

Common launchers:

```text
Orca
CloudCLI
Polaris
TOKENICODE
VS Code terminals/tasks
JetBrains terminals
Windows Terminal profiles
custom GUI launchers
background services
CI runners
remote controllers
Windows -> WSL wrappers
```

Common Agent CLIs:

```text
codex
claude
gemini
opencode
openclaw
hermes
```

---

## Core Rule

Provider mismatch is often not caused by `cc-switch` failing to switch.

It is often caused by the external program launching the Agent CLI with a different:

```text
user
HOME
PATH
working directory
config directory
CODEX_HOME
environment variables
old shell session
old GUI session
Windows-vs-WSL command path
missing proxy process
wrong API protocol
wrong local port
broken PowerShell -> WSL quoting
CRLF line endings
stale PowerShell variable
stdin/stdout capture behavior
terminal control sequences
```

Always inspect the **actual environment used by the external launcher**, not only a separate terminal.

---

## Quick Triage

Run these commands inside the terminal/session launched by the external app:

```bash
whoami
echo "HOME=$HOME"
echo "SHELL=${SHELL:-}"
echo "PWD=$PWD"
echo "PATH=$PATH"
echo "WSL_DISTRO_NAME=${WSL_DISTRO_NAME:-}"
env | sort | grep -Ei 'CODEX|CLAUDE|ANTHROPIC|OPENAI|HERMES|OPENCODE|OPENCLAW|GEMINI|GOOGLE|BASE|PROXY|API|TOKEN|KEY|HOME|PATH' || true
```

Redact secrets before sharing output.

Check CLI resolution:

```bash
type -a codex 2>/dev/null || true
type -a claude 2>/dev/null || true
type -a gemini 2>/dev/null || true
type -a opencode 2>/dev/null || true
type -a openclaw 2>/dev/null || true
type -a hermes 2>/dev/null || true
type -a cc-switch 2>/dev/null || true
```

For a specific CLI:

```bash
command -v <cli>
readlink -f "$(command -v <cli>)"
<cli> --version
```

Expected WSL/Linux user-local paths often look like:

```text
/home/agent/.local/bin/codex
/home/agent/.local/bin/claude
/home/agent/.local/bin/gemini
/home/agent/.local/bin/opencode
/home/agent/.local/bin/openclaw
/home/agent/.local/bin/hermes
/home/agent/.local/bin/cc-switch
```

Suspicious paths include:

```text
/mnt/c/Program Files/...
/mnt/c/Users/<WindowsUser>/...
/usr/local/bin/<cli> pointing to root-owned install
/root/.local/bin/<cli>
old npm global paths
old wrapper scripts
```

---

## cc-switch Checks

Check the cc-switch source-of-truth state:

```bash
cc-switch env tools
cc-switch --app <app> provider current
cc-switch --app <app> provider list
cc-switch env check --app <app>
```

Common app IDs:

```text
codex
claude
gemini
opencode
openclaw
hermes
```

If unsure, inspect the local version:

```bash
cc-switch --help
cc-switch provider --help
cc-switch provider add --help
cc-switch proxy --help
```

Important:

```text
cc-switch provider switch != proxy is running
cc-switch current correct != target Agent live config correct
cc-switch live config correct != external launcher environment correct
```

---

## Live Config Checks

`cc-switch` usually has two layers:

```text
1. cc-switch provider database / source config
2. live config written to the target Agent CLI
```

Always inspect the target Agent's live config after switching.

---

### Codex

Codex config is normally under:

```text
$CODEX_HOME/config.toml
```

If `CODEX_HOME` is unset, the default is usually:

```text
~/.codex/config.toml
```

Check:

```bash
echo "CODEX_HOME=${CODEX_HOME:-$HOME/.codex}"
cat "${CODEX_HOME:-$HOME/.codex}/config.toml" 2>/dev/null || true
test -f "${CODEX_HOME:-$HOME/.codex}/auth.json" && echo "auth.json exists"
```

For third-party OpenAI-compatible Responses providers, prefer an explicit custom model provider:

```toml
model_provider = "my-provider"
model = "your-model"

[model_providers.my-provider]
name = "My Provider"
base_url = "https://example.com/v1"
wire_api = "responses"
requires_openai_auth = false
```

Notes:

- Current Codex config uses `wire_api = "responses"` for the Responses API path.
- `requires_openai_auth = false` is important for third-party API-key providers.
- If `requires_openai_auth = true`, Codex may use official OpenAI auth behavior.
- Do not assume project config can override every user-level auth/provider field; verify the actual runtime output.

Correct runtime example:

```text
provider: congmingai
model: gpt-5.5
OK
```

Wrong runtime example:

```text
provider: openai
url: api.openai.com
401 Unauthorized
```

For reliable PowerShell -> WSL Codex verification, use the dedicated `$codexCheckScript` pattern in **PowerShell -> WSL Reliable Diagnostic Pattern** below.

---

### Claude Code

Claude Code supports environment variables in settings and shell environment. Check:

```bash
cat "$HOME/.claude/settings.json" 2>/dev/null || true
cat "$HOME/.claude/settings.local.json" 2>/dev/null || true
find "$PWD" -maxdepth 3 -path '*/.claude/settings*.json' -type f -print 2>/dev/null || true
env | sort | grep -Ei 'CLAUDE|ANTHROPIC|OPENAI|BASE|PROXY|TOKEN|KEY' || true
```

Common Claude provider-related variables:

```text
ANTHROPIC_BASE_URL
ANTHROPIC_AUTH_TOKEN
ANTHROPIC_API_KEY
ANTHROPIC_MODEL
ANTHROPIC_DEFAULT_OPUS_MODEL
ANTHROPIC_DEFAULT_SONNET_MODEL
ANTHROPIC_DEFAULT_HAIKU_MODEL
```

Important:

- `ANTHROPIC_BASE_URL` changes the API endpoint.
- `ANTHROPIC_AUTH_TOKEN` is commonly used for custom auth/proxy tokens.
- `ANTHROPIC_API_KEY` may override subscription-based auth behavior.
- Project-local Claude settings can differ from user settings depending on `PWD`.

For reliable PowerShell -> WSL Claude verification, use the dedicated `$claudeCheckScript` pattern in **PowerShell -> WSL Reliable Diagnostic Pattern** below.

---

### Gemini CLI

Inspect environment and config:

```bash
env | sort | grep -Ei 'GEMINI|GOOGLE|MODEL|BASE|PROXY|TOKEN|KEY' || true
ls -la "$HOME/.gemini" "$HOME/.config/gemini" 2>/dev/null || true
find "$HOME/.gemini" "$HOME/.config/gemini" -maxdepth 3 -type f 2>/dev/null || true
```

Common official/API-related variables may include:

```text
GEMINI_API_KEY
GOOGLE_API_KEY
GOOGLE_CLOUD_PROJECT
GOOGLE_CLOUD_LOCATION
```

Use local help for exact one-shot/headless syntax:

```bash
gemini --help
```

Do not assume Gemini uses Codex or Claude config semantics.

---

### OpenCode

OpenCode commonly uses JSON config and provider/model settings. Inspect:

```bash
ls -la "$HOME/.config/opencode" "$HOME/.opencode" 2>/dev/null || true
find "$HOME/.config/opencode" "$HOME/.opencode" -maxdepth 4 -type f 2>/dev/null || true
env | sort | grep -Ei 'OPENCODE|OPENAI|ANTHROPIC|GEMINI|GOOGLE|BASE|PROXY|TOKEN|KEY' || true
opencode --help
```

Use the current OpenCode docs and local CLI help for exact provider schema. Do not assume another Agent's config format applies to OpenCode.

---

### OpenClaw

Inspect both cc-switch state and local config:

```bash
ls -la "$HOME/.openclaw" "$HOME/.config/openclaw" 2>/dev/null || true
find "$HOME/.openclaw" "$HOME/.config/openclaw" -maxdepth 4 -type f 2>/dev/null || true
env | sort | grep -Ei 'OPENCLAW|OPENAI|ANTHROPIC|GEMINI|GOOGLE|BASE|PROXY|TOKEN|KEY' || true
openclaw --help
```

Use the current OpenClaw docs and local CLI help for exact schema.

---

### Hermes

Hermes distributions/config formats may vary. Do not guess. Inspect:

```bash
ls -la "$HOME/.hermes" "$HOME/.config/hermes" 2>/dev/null || true
find "$HOME/.hermes" "$HOME/.config/hermes" -maxdepth 4 -type f 2>/dev/null || true
env | sort | grep -Ei 'HERMES|OPENAI|ANTHROPIC|GEMINI|GOOGLE|BASE|PROXY|TOKEN|KEY' || true
hermes --help
```

Use:

```bash
cc-switch --app hermes provider current
cc-switch --app hermes provider list
cc-switch env check --app hermes
```

---

## Protocol Compatibility Rule

Every time you add or switch a provider for an Agent, check protocol compatibility.

Ask:

```text
1. What protocol does the Agent CLI speak?
2. What protocol does the provider expose?
3. Does direct configuration work?
4. Is a proxy/adapter required?
5. If proxy is required, is it actually running?
```

Typical protocol map:

```text
Codex        -> OpenAI Responses API in current official config path
Claude Code  -> Anthropic API protocol
Gemini CLI   -> Gemini / Google API protocol
OpenCode     -> provider-specific; verify config/docs
OpenClaw     -> provider-specific; verify config/docs
Hermes       -> provider-specific; verify config/docs
```

Common cases:

```text
Codex + OpenAI-compatible Responses provider
=> usually direct config is possible.

Claude Code + OpenAI-compatible provider
=> usually requires protocol conversion proxy.

Gemini CLI + OpenAI-compatible provider
=> usually requires adapter/proxy unless the tool/provider natively supports it.

Any Agent + provider says "Requires proxy"
=> provider switch alone is not enough; proxy must run.
```

---

## cc-switch Proxy

`cc-switch proxy` is used when the target Agent and provider do not speak the same API protocol, or when cc-switch needs to take over local endpoint configuration.

Check proxy state:

```bash
cc-switch proxy show
```

Inspect supported commands:

```bash
cc-switch proxy --help
cc-switch proxy serve --help
cc-switch proxy config --help
cc-switch proxy enable --help
```

### Foreground proxy for testing

Use foreground `serve` for debugging or temporary sessions:

```bash
cc-switch proxy serve --takeover claude
```

If your local version supports explicit address/port:

```bash
cc-switch proxy serve --listen-address 127.0.0.1 --listen-port 15721 --takeover claude
```

Keep this terminal alive while testing.

Verify port:

```bash
ss -ltnp 2>/dev/null | grep -E '15721|cc-switch' || true
```

If `ss` is unavailable:

```bash
netstat -ltnp 2>/dev/null | grep -E '15721|cc-switch' || true
lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | grep -E '15721|cc-switch' || true
```

### Persistent proxy

Do not assume opening `cc-switch` once starts a long-running proxy.

Preferred order:

```text
1. Use cc-switch's own proxy daemon/enable feature if supported.
2. Verify with cc-switch proxy show.
3. If daemon mode is unavailable or unreliable in the environment, use a user service or shell autostart.
```

For Linux/WSL/macOS, if supported by your version:

```bash
cc-switch --app claude proxy enable
cc-switch proxy show
```

For foreground/manual mode:

```bash
cc-switch proxy serve --takeover claude
```

This must keep running.

For WSL:

- If WSL shuts down, foreground proxy processes stop.
- If external launchers start Agents after WSL restart, configure daemon mode or an autostart script.
- If systemd user services are enabled and reliable, a user service is acceptable.
- If systemd is not enabled in WSL, use shell/launcher autostart.

For Windows-native mode:

- Check current cc-switch docs/help.
- If daemon mode is not supported, use foreground `serve` or a Windows service/task wrapper.

Correct Claude proxy state example:

```text
Local Proxy
Running: yes
Active routes: Claude=on
Listen address: 127.0.0.1
Proxy app routes:
- Claude: enabled, configured 15721
Current providers:
- claude: <expected-provider>
Routes:
- Claude: /v1/messages, /claude/v1/messages
```

---

## Claude + OpenAI-Compatible Provider Example

Claude Code speaks Anthropic protocol. Many third-party providers expose OpenAI Chat or OpenAI Responses protocol.

Therefore, Claude + OpenAI-compatible provider usually needs cc-switch proxy.

Recommended workflow:

```bash
cc-switch --app claude provider add --help
```

When adding the provider, choose an API format compatible with the upstream provider, for example:

```text
openai_chat
openai_responses
```

Then switch:

```bash
cc-switch --app claude provider switch <provider-id>
cc-switch --app claude provider current
cc-switch env check --app claude
```

Start or enable proxy:

```bash
cc-switch proxy serve --takeover claude
```

Or, if supported and desired:

```bash
cc-switch --app claude proxy enable
cc-switch proxy show
```

If `openai_responses` conversion fails with provider-specific unsupported parameters, try recreating/switching the provider with `openai_chat` if the upstream provider supports Chat Completions better.

Use the reliable diagnostic pattern below for real PowerShell -> WSL verification.

---

## Codex + OpenAI-Compatible Responses Example

Codex can usually call an OpenAI-compatible Responses provider directly through `config.toml`.

Example:

```toml
model_provider = "custom-responses"
model = "gpt-5.5"

[model_providers.custom-responses]
name = "Custom Responses Provider"
base_url = "https://example.com/v1"
wire_api = "responses"
requires_openai_auth = false
```

Then inspect:

```bash
cat "${CODEX_HOME:-$HOME/.codex}/config.toml"
```

If runtime still shows:

```text
provider: openai
url: api.openai.com
```

then check:

```text
CODEX_HOME
HOME
PATH
actual external launcher user
old session
wrong codex binary
cc-switch live config
```

Use the reliable diagnostic pattern below for real PowerShell -> WSL verification.

---

## WSL / Windows External Launcher Fixes

When Windows launches a WSL Agent, force the correct distro and user.

Basic one-liner checks are allowed for simple environment inspection only:

```powershell
wsl.exe -d Agent_Dev_Env1 --user agent -- bash -lc 'whoami; echo "$HOME"; command -v codex; codex --version'
```

Expected:

```text
agent
/home/agent
/home/agent/.local/bin/codex
codex-cli <version>
```

Another simple stdout check:

```powershell
wsl.exe -d Agent_Dev_Env1 --user agent -- bash -lc 'echo "__ONLY_ECHO__"; whoami; echo "$HOME"; exit 0'
$LASTEXITCODE
```

Expected:

```text
__ONLY_ECHO__
agent
/home/agent
0
```

Do not use complex PowerShell -> WSL one-liners as the final provider verification.

These are smoke tests only and may show no visible output in PowerShell even when the Agent succeeds:

```powershell
wsl.exe -d Agent_Dev_Env1 --user agent -- bash -lc 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"; export CODEX_HOME="$HOME/.codex"; codex exec "Say OK" --skip-git-repo-check </dev/null'
```

```powershell
wsl.exe -d Agent_Dev_Env1 --user agent -- bash -lc 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"; claude -p "Say OK" </dev/null'
```

If these return `$LASTEXITCODE = 0` but no visible output, do not conclude failure. Use the reliable log-file diagnostic pattern below.

If the launcher has a provider/account setting, make sure it uses the WSL-side user/account/config, not a Windows-native account.

---

## PowerShell -> WSL Reliable Diagnostic Pattern

Use this section for real Agent request verification from Windows PowerShell into WSL.

### Rules

Do:

```text
- Use a fresh, explicit variable for each check.
- Prefer names like $codexCheckScript and $claudeCheckScript.
- Print the script Length before piping it to WSL.
- Throw if the script variable is empty.
- Pipe the script through stdin into WSL.
- Strip CRLF using tr -d '\r'.
- Write WSL-side output to /tmp/*.log.
- Read logs with cat -v.
- Use </dev/null for one-shot Agent CLI calls.
- Check $LASTEXITCODE.
```

Do not:

```text
- Do not reuse a generic $script variable across examples.
- Do not rely on stale PowerShell variables.
- Do not depend on wslpath for temporary Windows script files.
- Do not paste PowerShell here-strings into WSL Bash.
- Do not treat empty log + exit code 0 as proof that Agent ran.
```

Bad pattern:

```powershell
($script -replace "`r`n", "`n") | wsl.exe -d <Distro> --user <User> -- bash -lc "cat > /tmp/check.sh && bash /tmp/check.sh"
```

Why bad:

```text
If $script is empty or stale, WSL may execute an empty or wrong script, return exit code 0, and produce an empty log.
```

If the prompt changes from:

```text
PS C:\...>
```

to:

```text
agent@host:/...$
```

you are now inside WSL Bash. Type:

```bash
exit
```

Do not paste PowerShell here-strings into Bash.

---

### Reliable Codex PowerShell -> WSL Check

Run this entire block in PowerShell:

```powershell
$codexCheckScript = @'
#!/usr/bin/env bash
set -u

echo "__START_CODEX__"
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"
export CODEX_HOME="$HOME/.codex"

echo "USER=$(whoami) HOME=$HOME CODEX_HOME=$CODEX_HOME"
command -v codex
codex --version

codex exec "Say OK" --skip-git-repo-check </dev/null
rc=$?

echo "__EXIT_CODEX__:$rc"
exit "$rc"
'@

"PowerShell script length: $($codexCheckScript.Length)"
if ($codexCheckScript.Length -le 0) { throw "codexCheckScript is empty" }

($codexCheckScript -replace "`r`n", "`n") |
  wsl.exe -d Agent_Dev_Env1 --user agent -- bash -lc "cat | tr -d '\r' > /tmp/codex-check.sh && bash /tmp/codex-check.sh > /tmp/codex-one-shot.log 2>&1 < /dev/null"

$LASTEXITCODE

wsl.exe -d Agent_Dev_Env1 --user agent -- bash -lc 'cat -v /tmp/codex-one-shot.log'
```

Correct Codex result example:

```text
__START_CODEX__
USER=agent HOME=/home/agent CODEX_HOME=/home/agent/.codex
/home/agent/.local/bin/codex
codex-cli <version>
provider: <expected-provider>
model: <expected-model>
OK
__EXIT_CODEX__:0
```

In the known good `Agent_Dev_Env1` case, expected provider/model were:

```text
provider: congmingai
model: gpt-5.5
```

---

### Reliable Claude PowerShell -> WSL Check

Run this entire block in PowerShell:

```powershell
$claudeCheckScript = @'
#!/usr/bin/env bash
set -u

echo "__START_CLAUDE__"
export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"

echo "USER=$(whoami) HOME=$HOME"
command -v claude
claude --version

echo "__CC_SWITCH_PROXY__"
cc-switch proxy show 2>/dev/null || true

claude -p "Say OK" </dev/null
rc=$?

echo "__EXIT_CLAUDE__:$rc"
exit "$rc"
'@

"PowerShell script length: $($claudeCheckScript.Length)"
if ($claudeCheckScript.Length -le 0) { throw "claudeCheckScript is empty" }

($claudeCheckScript -replace "`r`n", "`n") |
  wsl.exe -d Agent_Dev_Env1 --user agent -- bash -lc "cat | tr -d '\r' > /tmp/claude-check.sh && bash /tmp/claude-check.sh > /tmp/claude-one-shot.log 2>&1 < /dev/null"

$LASTEXITCODE

wsl.exe -d Agent_Dev_Env1 --user agent -- bash -lc 'cat -v /tmp/claude-one-shot.log'
```

Correct Claude result example:

```text
__START_CLAUDE__
USER=agent HOME=/home/agent
/home/agent/.local/bin/claude
<version> (Claude Code)
__CC_SWITCH_PROXY__
Local Proxy
Running: yes
Active routes: Claude=on
Current providers:
- claude: <expected-provider>
OK
__EXIT_CLAUDE__:0
```

In the known good `Agent_Dev_Env1` case, expected proxy/provider were:

```text
Running: yes
Claude: enabled, configured 15721
claude: congmingai-claude-openai-chat
```

---

### Why this pattern is preferred

```text
- avoids fragile long one-liners
- avoids unreliable wslpath conversion
- avoids stale generic $script variables
- verifies script is non-empty before execution
- removes Windows CRLF before Bash parses redirects
- stores output even if Agent clears or rewrites terminal
- cat -v exposes ANSI/control characters
- </dev/null prevents Agent CLIs from reading diagnostic stdin as extra prompt input
```

---

## Stable PATH and Config Home

For WSL/Linux Agent users, prefer user-local CLI paths:

```bash
mkdir -p "$HOME/.local/bin"
```

Ensure PATH is present in both login and interactive shells:

```bash
grep -qxF 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"' "$HOME/.profile" 2>/dev/null || \
  printf '\nexport PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"\n' >> "$HOME/.profile"

grep -qxF 'export PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"' "$HOME/.bashrc" 2>/dev/null || \
  printf '\nexport PATH="$HOME/.local/bin:$HOME/.npm-global/bin:$PATH"\n' >> "$HOME/.bashrc"
```

For Codex only, set `CODEX_HOME` when an external launcher must be deterministic:

```bash
grep -qxF 'export CODEX_HOME="$HOME/.codex"' "$HOME/.profile" 2>/dev/null || \
  printf '\nexport CODEX_HOME="$HOME/.codex"\n' >> "$HOME/.profile"

grep -qxF 'export CODEX_HOME="$HOME/.codex"' "$HOME/.bashrc" 2>/dev/null || \
  printf '\nexport CODEX_HOME="$HOME/.codex"\n' >> "$HOME/.bashrc"
```

Refresh current shell:

```bash
source "$HOME/.bashrc"
hash -r
```

Do not invent config-home variables for other Agents unless their official docs or local CLI help confirm them.

---

## Restart Stale Sessions

After switching providers, restart:

```text
old Agent tabs
old GUI launcher sessions
old IDE terminals
old Windows Terminal tabs
old WSL shells
background services
proxy process
```

External apps often cache:

```text
PATH
HOME
CODEX_HOME
ANTHROPIC_BASE_URL
provider
account
child process environment
working directory
local proxy port
```

For WSL-level changes, if necessary:

```powershell
wsl --terminate <DistroName>
```

or:

```powershell
wsl --shutdown
```

Then relaunch the distro/app.

---

## Common Failure Patterns

### cc-switch Correct, Real Execution Wrong

Symptom:

```text
cc-switch current = custom
doctor/check = custom
real exec = official provider / old endpoint
```

Check:

```text
external launcher environment
PATH
HOME
CODEX_HOME
wrong distro
wrong WSL user
old shell
old GUI session
project-local config
wrapper script
proxy process
protocol mismatch
```

---

### Live Config Wrong

Symptom:

```text
cc-switch current = custom
Agent live config still official/default
```

Fix:

```bash
cc-switch --app <app> provider switch <provider-id>
cc-switch env check --app <app>
```

Then inspect live config manually.

If still wrong, recreate the provider using the correct API format or raw config supported by the local cc-switch version.

---

### Protocol Wrong

Symptom:

```text
Claude Code configured directly against OpenAI-compatible endpoint
```

Likely fix:

```bash
cc-switch proxy serve --takeover claude
```

or persistent mode:

```bash
cc-switch --app claude proxy enable
cc-switch proxy show
```

If Responses conversion fails, try Chat conversion if upstream supports it.

---

### Proxy Not Running

Symptom:

```text
cc-switch proxy show -> not running
Agent config points to 127.0.0.1:<port>
connection refused
```

Fix:

```bash
cc-switch proxy serve --takeover <app>
```

or enable daemon mode if supported:

```bash
cc-switch --app <app> proxy enable
cc-switch proxy show
```

---

### Wrong User

Symptom:

```text
manual shell works as agent
external launcher runs as root or different user
```

Check:

```bash
whoami
echo "$HOME"
```

Fix the external launcher command:

```powershell
wsl.exe -d <DistroName> --user agent -- bash -lc '<simple-command>'
```

For complex diagnostics, use the explicit named script pattern instead of a long one-liner.

---

### PowerShell -> WSL No Output

Symptom:

```text
wsl.exe command returns $LASTEXITCODE = 0
but no visible output
```

Check the basic stdout path:

```powershell
wsl.exe -d <Distro> --user <User> -- bash -lc 'echo "__ONLY_ECHO__"; whoami; echo "$HOME"; exit 0'
$LASTEXITCODE
```

If simple echo works, the issue is likely:

```text
Agent CLI terminal behavior
stdout/stderr capture
ANSI control sequences
interactive TUI behavior
stdin behavior
```

Use the reliable log-file diagnostic pattern.

---

### PowerShell -> WSL Quoting Broken

Symptom:

```text
: > ;
syntax error near unexpected token `;'
HOME=/home/agent: -c: line 1
```

Cause:

```text
complex command was damaged by PowerShell -> wsl.exe -> bash -lc quoting
```

Fix:

```text
do not use complex one-liner
use a fresh named PowerShell here-string variable
check .Length
pipe it through stdin
write it to /tmp/check.sh
execute from WSL
```

---

### PowerShell -> WSL CRLF Broken

Symptom:

```text
ambiguous redirect
```

Cause:

```text
Bash parsed Windows CRLF as part of a redirection target, e.g. 2>&1\r
```

Fix:

```powershell
($namedCheckScript -replace "`r`n", "`n") |
  wsl.exe -d <Distro> --user <User> -- bash -lc "cat | tr -d '\r' > /tmp/check.sh && bash /tmp/check.sh > /tmp/check.log 2>&1 < /dev/null"
```

Do not use a generic stale `$script` variable.

---

### Empty Script, Empty Log, Exit Code 0

Symptom:

```text
/tmp/check.log is empty
$LASTEXITCODE = 0
```

Possible cause:

```text
PowerShell variable was empty or stale.
WSL executed an empty /tmp/check.sh successfully.
No Agent CLI actually ran.
```

Check before piping:

```powershell
"PowerShell script length: $($codexCheckScript.Length)"
if ($codexCheckScript.Length -le 0) { throw "codexCheckScript is empty" }
```

Use fresh names per check:

```text
$codexCheckScript
$claudeCheckScript
$geminiCheckScript
$opencodeCheckScript
$openclawCheckScript
$hermesCheckScript
```

Do not reuse:

```text
$script
```

---

## Minimal Debug Script for Linux/WSL Session

Use this inside the external launcher's actual Linux/WSL terminal/session.

Save as `agent-provider-debug.sh`:

```bash
#!/usr/bin/env bash
set -euo pipefail

APP="${1:-codex}"
CLI="${2:-codex}"

redact() {
  sed -E \
    -e 's/(sk-[A-Za-z0-9_-]{8})[A-Za-z0-9_-]+/\1<redacted>/g' \
    -e 's/((API|TOKEN|KEY|SECRET|PASSWORD)[A-Z0-9_]*[[:space:]]*[=:][[:space:]]*)[^[:space:]]+/\1<redacted>/Ig' \
    -e 's/("(API|TOKEN|KEY|SECRET|PASSWORD)[A-Z0-9_]*"[[:space:]]*:[[:space:]]*)"[^"]*"/\1"<redacted>"/Ig'
}

echo "== identity =="
whoami
echo "HOME=$HOME"
echo "SHELL=${SHELL:-}"
echo "PWD=$PWD"
echo "WSL_DISTRO_NAME=${WSL_DISTRO_NAME:-}"

echo "== env =="
env | sort | grep -Ei 'CODEX|CLAUDE|ANTHROPIC|OPENAI|HERMES|OPENCODE|OPENCLAW|GEMINI|GOOGLE|BASE|PROXY|HOME|PATH|API|TOKEN|KEY' \
  | redact || true

echo "== cli path =="
type -a "$CLI" 2>/dev/null || true
if command -v "$CLI" >/dev/null 2>&1; then
  readlink -f "$(command -v "$CLI")" || true
  "$CLI" --version 2>/dev/null || true
else
  echo "$CLI not found"
fi

echo "== cc-switch =="
if command -v cc-switch >/dev/null 2>&1; then
  cc-switch --app "$APP" provider current 2>/dev/null | redact || true
  cc-switch --app "$APP" provider list 2>/dev/null | redact || true
  cc-switch env check --app "$APP" 2>/dev/null | redact || true

  echo "== proxy =="
  cc-switch proxy show 2>/dev/null | redact || true
else
  echo "cc-switch not found"
fi

echo "== listening ports =="
ss -ltnp 2>/dev/null | grep -E '15721|15722|15723|cc-switch' || true
netstat -ltnp 2>/dev/null | grep -E '15721|15722|15723|cc-switch' || true
lsof -iTCP -sTCP:LISTEN -P -n 2>/dev/null | grep -E '15721|15722|15723|cc-switch' || true

echo "== common config dirs =="
for d in \
  "$HOME/.codex" \
  "$HOME/.claude" \
  "$HOME/.gemini" \
  "$HOME/.hermes" \
  "$HOME/.opencode" \
  "$HOME/.openclaw" \
  "$HOME/.config/gemini" \
  "$HOME/.config/hermes" \
  "$HOME/.config/opencode" \
  "$HOME/.config/openclaw"; do
  [ -e "$d" ] && ls -ld "$d"
done

if [ "$APP" = "codex" ]; then
  echo "== codex config =="
  echo "CODEX_HOME=${CODEX_HOME:-$HOME/.codex}"
  cat "${CODEX_HOME:-$HOME/.codex}/config.toml" 2>/dev/null | redact || true
  test -f "${CODEX_HOME:-$HOME/.codex}/auth.json" && echo "auth.json exists"
fi

if [ "$APP" = "claude" ]; then
  echo "== claude config =="
  cat "$HOME/.claude/settings.json" 2>/dev/null | redact || true
  cat "$HOME/.claude/settings.local.json" 2>/dev/null | redact || true
  find "$PWD" -maxdepth 3 -path '*/.claude/settings*.json' -type f -print 2>/dev/null || true
fi

if [ "$APP" = "gemini" ]; then
  echo "== gemini config candidates =="
  find "$HOME/.gemini" "$HOME/.config/gemini" -maxdepth 4 -type f 2>/dev/null || true
fi

if [ "$APP" = "opencode" ]; then
  echo "== opencode config candidates =="
  find "$HOME/.opencode" "$HOME/.config/opencode" -maxdepth 4 -type f 2>/dev/null || true
fi

if [ "$APP" = "openclaw" ]; then
  echo "== openclaw config candidates =="
  find "$HOME/.openclaw" "$HOME/.config/openclaw" -maxdepth 4 -type f 2>/dev/null || true
fi

if [ "$APP" = "hermes" ]; then
  echo "== hermes config candidates =="
  find "$HOME/.hermes" "$HOME/.config/hermes" -maxdepth 4 -type f 2>/dev/null || true
fi
```

Usage:

```bash
chmod +x agent-provider-debug.sh

./agent-provider-debug.sh codex codex
./agent-provider-debug.sh claude claude
./agent-provider-debug.sh gemini gemini
./agent-provider-debug.sh opencode opencode
./agent-provider-debug.sh openclaw openclaw
./agent-provider-debug.sh hermes hermes
```

---

## Final Verification Checklist

After any provider change:

```bash
cc-switch --app <app> provider current
cc-switch env check --app <app>
type -a <cli>
readlink -f "$(command -v <cli>)"
<cli> --version
```

If proxy is required:

```bash
cc-switch proxy show
ss -ltnp 2>/dev/null | grep <port> || true
```

Run a real minimal request, not only doctor/check.

For PowerShell -> WSL, use explicit named script diagnostics:

```text
$codexCheckScript
$claudeCheckScript
```

For other CLIs, create separate fresh variables:

```text
$geminiCheckScript
$opencodeCheckScript
$openclawCheckScript
$hermesCheckScript
```

Confirm:

```text
expected provider
expected model
expected endpoint or local proxy
expected user
expected config home
expected working directory
OK
exit code 0
non-empty diagnostic log
```

---

## Rules to Remember

1. Diagnose the actual external-launcher environment first.
2. Do not trust `cc-switch provider current` alone.
3. Inspect the target Agent live config after every switch.
4. Run a real minimal request, not only doctor/check.
5. Check protocol compatibility every time a provider is added.
6. If provider says proxy is required, start or enable `cc-switch proxy`.
7. `cc-switch provider switch` does not mean proxy is running.
8. Codex can often call OpenAI-compatible Responses providers directly.
9. Claude Code usually needs proxy for OpenAI-compatible providers.
10. If Responses conversion fails, try Chat conversion when the upstream provider supports it.
11. External launcher sessions must be restarted after provider/env changes.
12. WSL launchers must specify the correct distro and user.
13. Simple PowerShell -> WSL one-liners are only for basic env checks.
14. Complex PowerShell -> WSL diagnostics must use fresh named script variables.
15. Never rely on a generic stale `$script` variable.
16. Always check PowerShell script `.Length` before piping to WSL.
17. Strip CRLF with `tr -d '\r'` before Bash executes generated scripts.
18. Write Agent request output to WSL-side logs and inspect with `cat -v`.
19. Use `< /dev/null` for one-shot Agent CLI tests to avoid stdin prompt injection.
20. Empty log + exit code 0 may mean an empty script ran, not that Agent succeeded.
21. Always redact API keys and tokens in logs.

