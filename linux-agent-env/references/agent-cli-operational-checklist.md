# Agent CLI Operational Checklist

Use this reference after installing Agent CLIs or when an external Agent cannot find `claude`, `codex`, `cc-switch`, or cannot apply provider settings reliably. These notes are based on real deployment pitfalls: user/root split, non-interactive PATH, broken symlinks, mixed install methods, and cc-switch/Codex provider edge cases.

## Short Principles

1. **Fixed normal user**: install and run Agent CLIs as the normal `agent` user; do not mix root and user config.
2. **Fixed entry path**: prefer `~/.local/bin/<tool>` as the stable user-level entrypoint.
3. **Global fallback symlink**: if needed, link `/usr/local/bin/<tool>` to `/home/agent/.local/bin/<tool>`, not directly to random version/cache paths.
4. **Fixed PATH**: ensure `~/.local/bin` is in PATH; automation should explicitly set PATH.
5. **Verify resolution**: use `type -a`, `command -v`, `readlink -f`, and `--version`.
6. **Avoid mixed installs**: do not let apt/npm/standalone/root/user installs shadow each other silently.
7. **Per-app provider configs**: Claude, Codex, Gemini, OpenCode, Hermes, OpenClaw, etc. should have separate provider entries.
8. **Prefer native protocol**: use direct native API configuration when upstream already supports the target app protocol; use cc-switch proxy/adapter only for conversion or takeover.
9. **Local proxy must persist**: any config pointing to `127.0.0.1`/`localhost` requires a running process and a listening port.
10. **Codex custom Responses provider must be explicit**: set `wire_api = "responses"` and `requires_openai_auth = false` for third-party API-key providers unless current Codex docs/provider docs say otherwise.
11. **Do not rely on implicit field-mode generation for Codex**: use `--config-file` with raw config when field-mode output is wrong or ambiguous.
12. **cc-switch database is source-of-truth**: do not only edit live config; provider switch can overwrite live files.

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

Optional global fallback symlinks for external tools that do not use the user's PATH:

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
