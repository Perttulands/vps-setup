#!/usr/bin/env bash
set -euo pipefail

# =============================================================================
# Agentic Coding VPS Setup
# Complete installation for OpenClaw + agent swarm + monitoring
# =============================================================================

STEP=0
total_steps=15
step() { STEP=$((STEP + 1)); echo ""; echo "[$STEP/$total_steps] $1"; echo "---"; }

LOCAL_BIN="$HOME/.local/bin"
WORKSPACE="$HOME/.openclaw/workspace"

echo "=== Agentic Coding VPS Setup ==="
echo "This will install:"
echo "  - OpenClaw Gateway + MCP Agent Mail"
echo "  - Agent dispatch system (swarm scripts)"
echo "  - Argus ops watchdog"
echo "  - Workspace templates and skills"
echo "  - Recommended CLI tools"
echo ""

# --- System Update ---
step "Updating system packages"
sudo apt update && sudo apt upgrade -y

# --- Core Tools ---
step "Installing core tools"
sudo apt install -y \
    git \
    curl \
    wget \
    unzip \
    lsof \
    jq \
    tmux \
    build-essential \
    software-properties-common

# --- Node.js (required for athena-web and OpenClaw) ---
step "Installing Node.js"
if ! command -v node &> /dev/null; then
    curl -fsSL https://deb.nodesource.com/setup_20.x | sudo -E bash -
    sudo apt-get install -y nodejs
    echo "  -> Installed: $(node --version)"
else
    echo "  -> Already installed: $(node --version)"
fi

# --- GitHub CLI ---
step "Installing GitHub CLI"
if ! command -v gh &> /dev/null; then
    (type -p wget >/dev/null || sudo apt-get install wget -y) \
    && sudo mkdir -p -m 755 /etc/apt/keyrings \
    && out=$(mktemp) && wget -nv -O"$out" https://cli.github.com/packages/githubcli-archive-keyring.gpg \
    && cat "$out" | sudo tee /etc/apt/keyrings/githubcli-archive-keyring.gpg > /dev/null \
    && sudo chmod go+r /etc/apt/keyrings/githubcli-archive-keyring.gpg \
    && echo "deb [arch=$(dpkg --print-architecture) signed-by=/etc/apt/keyrings/githubcli-archive-keyring.gpg] https://cli.github.com/packages stable main" \
        | sudo tee /etc/apt/sources.list.d/github-cli.list > /dev/null \
    && sudo apt update \
    && sudo apt install gh -y
    echo "  -> Installed. Run 'gh auth login' to authenticate."
else
    echo "  -> Already installed: $(gh --version | head -1)"
fi

# --- Tailscale ---
step "Installing Tailscale"
if ! command -v tailscale &> /dev/null; then
    curl -fsSL https://tailscale.com/install.sh | sh
    echo "  -> Installed. Run 'sudo tailscale up' to connect."
else
    echo "  -> Already installed: $(tailscale --version | head -1)"
fi

# --- Claude Code CLI ---
step "Installing Claude Code CLI"
if ! command -v claude &> /dev/null; then
    npm install -g @anthropic-ai/claude-code
    echo "  -> Installed. Run 'claude login' to authenticate."
else
    echo "  -> Already installed: $(claude --version 2>/dev/null | head -1)"
fi

# --- OpenClaw ---
step "Installing OpenClaw"
NPM_BIN="$(npm config get prefix 2>/dev/null)/bin"
export PATH="$NPM_BIN:$PATH"
if ! command -v openclaw &> /dev/null; then
    curl -fsSL https://openclaw.ai/install.sh | bash
    echo "  -> Installed. Run 'openclaw onboard' to configure."
else
    echo "  -> Already installed: $(openclaw --version 2>/dev/null)"
fi

# --- MCP Agent Mail ---
step "Installing MCP Agent Mail"
if [ ! -d "$HOME/mcp_agent_mail" ]; then
    curl -fsSL https://raw.githubusercontent.com/Dicklesworthstone/mcp_agent_mail/main/scripts/install.sh | bash -s -- --yes --no-start --dir "$HOME/mcp_agent_mail"
else
    echo "  -> Already installed at $HOME/mcp_agent_mail"
fi

# --- Workspace Setup ---
step "Setting up workspace"
mkdir -p "$WORKSPACE"/{scripts,templates,state/{runs,results,watch},memory,skills}

# Copy swarm scripts
if [ -d "swarm/scripts" ]; then
    echo "  -> Copying swarm scripts..."
    cp -r swarm/scripts/* "$WORKSPACE/scripts/"
    chmod +x "$WORKSPACE/scripts/"*.sh
fi

# Copy templates
if [ -d "swarm/templates" ]; then
    echo "  -> Copying templates..."
    cp -r swarm/templates/* "$WORKSPACE/templates/"
fi

# Copy workspace files
if [ -d "workspace" ]; then
    echo "  -> Copying workspace files..."
    cp workspace/AGENTS.md "$WORKSPACE/"
    cp workspace/TOOLS.md "$WORKSPACE/"
    if [ ! -f "$WORKSPACE/SOUL.md" ]; then
        cp workspace/SOUL.md.example "$WORKSPACE/SOUL.md"
        echo "  -> Created SOUL.md (customize it!)"
    fi
    if [ ! -f "$WORKSPACE/USER.md" ]; then
        cp workspace/USER.md.example "$WORKSPACE/USER.md"
        echo "  -> Created USER.md (customize it!)"
    fi
fi

# Copy skills
if [ -d "skills" ]; then
    echo "  -> Copying skills..."
    cp -r skills/* "$WORKSPACE/skills/"
fi

echo "  -> Workspace ready at $WORKSPACE"

# --- Argus Setup ---
step "Setting up Argus watchdog"
ARGUS_DIR="$HOME/argus"
if [ -d "argus" ]; then
    echo "  -> Copying Argus files..."
    mkdir -p "$ARGUS_DIR"
    cp argus/*.sh "$ARGUS_DIR/"
    cp argus/*.md "$ARGUS_DIR/"
    cp argus/argus.env.example "$ARGUS_DIR/"
    cp services/argus.service "$ARGUS_DIR/"
    chmod +x "$ARGUS_DIR/"*.sh
    echo "  -> Argus files copied to $ARGUS_DIR"
    echo "  -> Create argus.env before installing service"
fi

# --- Flywheel Tools (prebuilt binaries) ---
step "Installing flywheel tools"
mkdir -p "$LOCAL_BIN"

install_binary() {
    local name="$1" url="$2" dest="$LOCAL_BIN/$name"
    if [ -f "$dest" ]; then
        echo "  -> $name already installed"
        return
    fi
    echo "  -> Installing $name..."
    local tmp=$(mktemp -d)
    curl -fsSL "$url" -o "$tmp/archive"
    case "$url" in
        *.tar.gz) tar xzf "$tmp/archive" -C "$tmp" ;;
        *.tar.xz) tar xf "$tmp/archive" -C "$tmp" ;;
        *)        mv "$tmp/archive" "$tmp/$name" ;;
    esac
    local bin=$(find "$tmp" -type f -name "$name" | head -1)
    if [ -z "$bin" ]; then bin=$(find "$tmp" -type f -executable | head -1); fi
    mv "$bin" "$dest"
    chmod +x "$dest"
    rm -rf "$tmp"
    echo "  -> $name installed"
}

install_binary cass "https://github.com/Dicklesworthstone/coding_agent_session_search/releases/latest/download/cass-linux-amd64.tar.gz"
install_binary dcg  "https://github.com/Dicklesworthstone/destructive_command_guard/releases/latest/download/dcg-x86_64-unknown-linux-gnu.tar.xz"
install_binary ntm  "https://github.com/Dicklesworthstone/ntm/releases/latest/download/ntm_1.7.0_linux_amd64.tar.gz"
install_binary slb  "https://github.com/Dicklesworthstone/slb/releases/latest/download/slb_0.1.0_linux_amd64.tar.gz"
install_binary ms   "https://github.com/Dicklesworthstone/meta_skill/releases/latest/download/ms-0.1.0-x86_64-unknown-linux-gnu.tar.gz"
install_binary ru   "https://github.com/Dicklesworthstone/repo_updater/releases/latest/download/ru"

# br and bv are installed by the MCP Agent Mail installer above

# --- PATH and aliases ---
step "Configuring shell"
NPM_BIN="$(npm config get prefix 2>/dev/null)/bin"
SHELL_RC="$HOME/.bashrc"
if [ -f "$HOME/.zshrc" ]; then SHELL_RC="$HOME/.zshrc"; fi

if ! grep -q "$NPM_BIN" "$SHELL_RC" 2>/dev/null; then
    echo "export PATH=\"$NPM_BIN:\$PATH\"" >> "$SHELL_RC"
fi
if ! grep -q ".local/bin" "$SHELL_RC" 2>/dev/null; then
    echo "export PATH=\"\$HOME/.local/bin:\$PATH\"" >> "$SHELL_RC"
fi
if ! grep -q "alias claude=" "$SHELL_RC" 2>/dev/null; then
    cat >> "$SHELL_RC" <<'ALIASES'

# Default flags for AI tools
alias claude='claude --dangerously-skip-permissions'
alias codex='codex --sandbox danger-full-access'
ALIASES
fi
echo "  -> Shell configured"

# --- Systemd services info ---
step "Systemd services (manual installation required)"
echo ""
echo "Service files are in the 'services/' directory:"
echo ""
echo "  OpenClaw Gateway:"
echo "    sudo cp services/openclaw-gateway.service /etc/systemd/system/"
echo "    sudo systemctl daemon-reload"
echo "    sudo systemctl enable --now openclaw-gateway"
echo ""
echo "  MCP Agent Mail:"
echo "    sudo cp services/mcp-agent-mail.service /etc/systemd/system/"
echo "    sudo systemctl daemon-reload"
echo "    sudo systemctl enable --now mcp-agent-mail"
echo ""
echo "  Argus (after creating argus.env):"
echo "    cd ~/argus && ./install.sh"
echo ""
echo "  Athena Web (if you have athena-web):"
echo "    sudo cp services/athena-web.service /etc/systemd/system/"
echo "    sudo systemctl daemon-reload"
echo "    sudo systemctl enable --now athena-web"
echo ""

# --- Final summary ---
step "Installation complete!"
echo ""
echo "=== Next Steps ==="
echo ""
echo "1. Authentication & Configuration:"
echo "     gh auth login"
echo "     git config --global user.name 'Your Name'"
echo "     git config --global user.email 'your@email.com'"
echo "     claude login"
echo "     sudo tailscale up"
echo "     openclaw onboard"
echo ""
echo "2. Customize your workspace:"
echo "     nano ~/.openclaw/workspace/SOUL.md"
echo "     nano ~/.openclaw/workspace/USER.md"
echo "     nano ~/.openclaw/workspace/TOOLS.md"
echo ""
echo "3. Configure Argus (optional):"
echo "     cd ~/argus"
echo "     cp argus.env.example argus.env"
echo "     nano argus.env  # Add your tokens"
echo "     ./install.sh"
echo ""
echo "4. Install systemd services (see output above)"
echo ""
echo "5. Test the system:"
echo "     br create --title 'Test task' --priority 1"
echo "     ~/.openclaw/workspace/scripts/poll-agents.sh"
echo ""
echo "Documentation:"
echo "  - Architecture: docs/architecture.md"
echo "  - Swarm system: swarm/README.md"
echo "  - Skills: skills/README.md"
echo "  - Tools: tools/README.md"
echo ""
