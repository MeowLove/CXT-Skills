# Optional Developer Toolchain Reference

Use this reference when the user asks for a complete Agent workstation, project-development environment, or enhanced tooling beyond locale/font/WSL basics. Do not install these during a minimal CJK/locale-only setup.

## Policy

- Install as the normal `agent` user where possible. Use `sudo` only for system packages.
- Prefer stable/LTS toolchains and official upstream installers when the distro package is too old for Agent tools.
- Keep project files in the Linux filesystem for WSL performance; avoid running large repositories directly under `/mnt/c/...` unless Windows-side tools require it.
- Do not install heavy GUI/runtime packages unless the user needs GUI apps, Playwright, Electron, or AppImage. For that case, use `references/gui-appimage-runtime.md`.

## Node.js LTS, npm, corepack, and pnpm

Rationale: many Agent tools, MCP servers, and front-end projects need a current Node.js even when Claude Code/Codex were installed through standalone/native routes.

Check first:

```bash
node --version 2>/dev/null || true
npm --version 2>/dev/null || true
corepack --version 2>/dev/null || true
pnpm --version 2>/dev/null || true
```

Preferred approach: follow the current Node.js/npm official guidance for Linux. npm docs recommend a Node version manager where possible; on Linux, NodeSource is a documented binary-distribution option when a version manager is unsuitable. If the user already has a standard Node policy, follow it.

Non-interactive Linux option with NodeSource after verifying the current LTS major from the Node.js download/release pages. Example uses Node.js 24 LTS; update `NODE_MAJOR` when official LTS changes:

```bash
NODE_MAJOR=24

# Debian/Ubuntu
curl -fsSL https://deb.nodesource.com/setup_${NODE_MAJOR}.x | sudo -E bash -
sudo apt install -y nodejs

# Fedora/RHEL-family
curl -fsSL https://rpm.nodesource.com/setup_${NODE_MAJOR}.x | sudo bash -
sudo dnf install -y nodejs

node --version
npm --version
```

After Node.js LTS and npm are present, enable pnpm through corepack. If `npm install --global` or `corepack enable` fails due permissions, do not use `sudo npm -g` by default; switch to a user-local Node install or use pnpm's standalone installer below.

```bash
npm install --global corepack@latest
corepack enable pnpm
corepack prepare pnpm@latest --activate 2>/dev/null || true
pnpm --version
```

If corepack is unavailable or broken, use pnpm's standalone installer on POSIX systems:

```bash
curl -fsSL https://get.pnpm.io/install.sh | sh -
# Restart shell or source the profile updated by the installer, then:
pnpm --version
```

Note: pnpm major-version requirements can change. If pnpm or the selected Agent requires a newer Node.js than the system package provides, install current Node.js LTS instead of relying on old distro packages.

## Python Toolchain Enhancements

Rationale: Python CLI tools and MCP servers should be isolated from system Python, especially on PEP 668 distros such as Debian 12, Ubuntu 23.04+, and Fedora 38+.

System prerequisites:

```bash
# Debian/Ubuntu
sudo apt update -y
sudo apt install -y python3 python3-pip python3-venv pipx

# Fedora/RHEL-family
sudo dnf install -y python3 python3-pip pipx
```

Install/verify uv. Prefer uv's official standalone installer, or use pipx isolation:

```bash
curl -LsSf https://astral.sh/uv/install.sh | sh
# or: pipx install uv
uv --version
```

Install common Python CLI tools with `uv tool` or `pipx` rather than system `pip`:

```bash
uv tool install ruff || pipx install ruff
uv tool install pytest || pipx install pytest
ruff --version
pytest --version
```

Use project-local environments for project dependencies:

```bash
cd /home/agent/workspace/<project>
uv venv
uv pip install -r requirements.txt  # when the project has one
uv run pytest
```

## Common Terminal Tools for Agent Work

Rationale: these tools improve code search, JSON inspection, navigation, multiplexing, and process visibility.

### Debian / Ubuntu

Install the core set first, then add optional tools only when available so one missing package does not abort the whole setup:

```bash
sudo apt update -y
sudo apt install -y ripgrep fd-find jq fzf tree htop tmux zsh curl git unzip tar xz-utils

for pkg in bat eza; do
  if apt-cache show "$pkg" >/dev/null 2>&1; then
    sudo apt install -y "$pkg"
  else
    echo "Optional package $pkg is not available in enabled apt repositories; skip or add an approved repository."
  fi
done
```

Debian/Ubuntu package names sometimes install `fd` as `fdfind` and `bat` as `batcat`. Add user-level aliases if needed:

```bash
if command -v fdfind >/dev/null 2>&1 && ! grep -qxF 'alias fd=fdfind' ~/.bashrc 2>/dev/null; then echo 'alias fd=fdfind' >> ~/.bashrc; fi
if command -v batcat >/dev/null 2>&1 && ! grep -qxF 'alias bat=batcat' ~/.bashrc 2>/dev/null; then echo 'alias bat=batcat' >> ~/.bashrc; fi
```

### Fedora / RHEL-family

Install the core set first, then query optional packages before installing them:

```bash
sudo dnf install -y ripgrep fd-find jq fzf tree htop tmux zsh curl git unzip tar xz

for pkg in bat eza; do
  if dnf list --available "$pkg" >/dev/null 2>&1 || dnf list --installed "$pkg" >/dev/null 2>&1; then
    sudo dnf install -y "$pkg"
  else
    echo "Optional package $pkg is not available in enabled dnf repositories; skip or add an approved repository."
  fi
done
```

On older RHEL-family systems, `eza` or `bat` may need EPEL or may be unavailable. Query first instead of enabling third-party repositories without user approval.


## Git Identity and SSH for Private Repositories

Rationale: Agent workstations often need to clone private repos, create commits, push branches, or authenticate to GitHub/GitLab/Bitbucket. Configure this only when the user provides the real name/email and wants Git/SSH ready; do not invent identity values.

Check current Git identity:

```bash
git config --global --get user.name || true
git config --global --get user.email || true
git config --global --get init.defaultBranch || true
```

Set identity and default branch after the user provides values:

```bash
git config --global user.name "Your Name"
git config --global user.email "you@example.com"
git config --global init.defaultBranch main
```

Optional useful Git defaults for Agent workstations. Treat these as user preferences, not mandatory settings:

```bash
# Pick the merge/rebase behavior the user wants; this example keeps merge-based pulls.
git config --global pull.rebase false

# Set an editor only when the editor exists and the user wants it.
command -v nano >/dev/null 2>&1 && git config --global core.editor "nano"

git config --global --list --show-origin
```

Create an SSH key only when the user needs SSH/private repository access and does not already have a suitable key. Prefer Ed25519 keys, and use the user's Git hosting email/comment:

```bash
ls -la ~/.ssh 2>/dev/null || true
ssh-keygen -t ed25519 -C "you@example.com" -f ~/.ssh/id_ed25519
```

Start an agent and add the key for the current shell/session:

```bash
eval "$(ssh-agent -s)"
ssh-add ~/.ssh/id_ed25519
```

Show/copy the public key so the user can add it to the Git hosting account:

```bash
cat ~/.ssh/id_ed25519.pub

# WSL convenience: copy to Windows clipboard when clip.exe is available
cat ~/.ssh/id_ed25519.pub | clip.exe 2>/dev/null || true
```

If GitHub CLI is installed and authenticated, it can upload the key directly:

```bash
gh auth status
gh ssh-key add ~/.ssh/id_ed25519.pub --title "$(hostname)-agent"
```

Test GitHub SSH access after the public key is added:

```bash
ssh -T git@github.com
```

Expected GitHub behavior is a successful authentication message that may also say shell access is not provided. For GitLab/Bitbucket, use that provider's equivalent SSH test host. If `ssh -T` fails, check key permissions and remote URL:

```bash
chmod 700 ~/.ssh
chmod 600 ~/.ssh/id_ed25519
chmod 644 ~/.ssh/id_ed25519.pub
git remote -v
```

Do not copy private keys into shared logs, prompts, repos, or screenshots. Only the `.pub` public key should be shared.

## Starship Prompt

Optional. Useful for readable prompts, but it modifies shell startup files. Install only if the user wants shell UI enhancements.

```bash
curl -sS https://starship.rs/install.sh | sh
echo 'eval "$(starship init bash)"' >> ~/.bashrc
# zsh users:
# echo 'eval "$(starship init zsh)"' >> ~/.zshrc
```

## WSL Workspace Directories

For WSL, create work directories inside the Linux ext4 filesystem for better metadata and filesystem performance than `/mnt/c/...` on large repos:

```bash
mkdir -p /home/agent/workspace /home/agent/projects /home/agent/tools
sudo chown -R agent:agent /home/agent/workspace /home/agent/projects /home/agent/tools
```

Recommended usage:

```bash
cd /home/agent/workspace
git clone <repo-url>
```

Use `/mnt/c/...` only when the project must be edited directly by Windows-native tools. If sharing with Windows editors, prefer opening the WSL path through the editor's WSL integration instead of copying the repo to NTFS.

## GUI/AppImage/Electron Runtime

Do not install GUI runtime libraries by default for headless Agent work. If the user needs GUI apps, Playwright browsers, Electron tools, AppImage utilities, or CC-Switch GUI, load `references/gui-appimage-runtime.md` and install the minimal distro-specific package set there.
