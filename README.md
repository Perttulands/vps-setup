# Agentic Coding VPS Template

A complete, ready-to-clone template for setting up an agentic coding environment on a VPS. This system enables AI-orchestrated software development through:
- Multi-agent task decomposition and parallel execution
- Autonomous coding agents (Claude Code, Codex)
- Automated monitoring and quality gates
- Structured state tracking for continuous improvement

## What This System Does

```
You → Coordinator AI → Dispatch Agents → Monitor → Verify → Report Results
```

1. **You** describe what needs to be built
2. **Coordinator** (Athena) decomposes work into discrete tasks (beads)
3. **Agents** work autonomously in isolated environments
4. **Watchers** monitor progress without blocking
5. **Verifiers** check quality automatically
6. **System** learns from structured execution history

## Architecture Overview

```
┌─────────────────────────────────────────────┐
│  User Interface (Telegram/SSH/Web)          │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│  OpenClaw Gateway (Orchestration Hub)       │
│  + MCP Agent Mail (Agent Messaging)         │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│  Agent Swarm (dispatch.sh)                  │
│  • Claude Code agents                       │
│  • Codex agents                             │
│  • Isolated tmux sessions                   │
└────────────────┬────────────────────────────┘
                 │
┌────────────────▼────────────────────────────┐
│  Monitoring (Argus + Watchers)              │
│  • Service health checks                    │
│  • Agent completion detection               │
│  • Automated recovery                       │
└─────────────────────────────────────────────┘
```

See [docs/architecture.md](docs/architecture.md) for detailed architecture documentation.

## Quick Start

### 1. Clone and Run Setup

```bash
git clone https://github.com/your-username/vps-setup.git
cd vps-setup
chmod +x setup.sh
./setup.sh
```

This installs:
- Core system tools (git, jq, tmux, node)
- OpenClaw + MCP Agent Mail
- Claude Code CLI
- Agent dispatch system
- Workspace templates
- Recommended utilities

### 2. Configure Authentication

```bash
# GitHub
gh auth login

# Git identity
git config --global user.name "Your Name"
git config --global user.email "your@email.com"

# Claude Code
claude login

# Tailscale VPN (optional but recommended)
sudo tailscale up

# OpenClaw
openclaw onboard
```

### 3. Customize Your Workspace

```bash
# Edit identity files
nano ~/.openclaw/workspace/SOUL.md   # AI coordinator identity
nano ~/.openclaw/workspace/USER.md   # Your profile
nano ~/.openclaw/workspace/TOOLS.md  # Server info
```

### 4. Install System Services

```bash
# OpenClaw Gateway
sudo cp services/openclaw-gateway.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now openclaw-gateway

# MCP Agent Mail
sudo cp services/mcp-agent-mail.service /etc/systemd/system/
sudo systemctl daemon-reload
sudo systemctl enable --now mcp-agent-mail

# Argus (optional ops watchdog)
cd ~/argus
cp argus.env.example argus.env
nano argus.env  # Add TELEGRAM_BOT_TOKEN and TELEGRAM_CHAT_ID
./install.sh
```

### 5. Test the System

```bash
# Create a test task
br create --title "Test agent dispatch" --priority 1

# Get the bead ID from output (e.g., "abc123")
BEAD_ID="abc123"

# Dispatch an agent
cd ~/.openclaw/workspace
./scripts/dispatch.sh $BEAD_ID ~/your-repo claude "Create a simple hello world script"

# Monitor agents
./scripts/poll-agents.sh

# View results
cat state/results/$BEAD_ID.json | jq
```

## Repository Structure

```
vps-setup/
├── README.md                    # This file
├── setup.sh                     # Main installation script
├── .gitignore                   # Excludes secrets and logs
│
├── services/                    # systemd service unit files
│   ├── openclaw-gateway.service
│   ├── mcp-agent-mail.service
│   ├── athena-web.service
│   └── argus.service
│
├── argus/                       # Ops watchdog (AI-powered monitoring)
│   ├── argus.sh
│   ├── collectors.sh
│   ├── actions.sh
│   ├── prompt.md
│   ├── install.sh
│   ├── argus.env.example
│   └── README.md
│
├── swarm/                       # Agent dispatch system
│   ├── scripts/
│   │   ├── dispatch.sh          # Core agent launcher
│   │   ├── verify.sh            # Quality verification
│   │   ├── agent-preflight.sh   # Environment checks
│   │   └── poll-agents.sh       # Status monitoring
│   ├── templates/               # Prompt templates
│   │   ├── feature.md
│   │   ├── bug-fix.md
│   │   ├── refactor.md
│   │   └── ...
│   └── README.md
│
├── workspace/                   # Workspace template files
│   ├── AGENTS.md                # Entry point for AI
│   ├── TOOLS.md                 # Server reference
│   ├── SOUL.md.example          # AI identity template
│   ├── USER.md.example          # User profile template
│   └── memory/.gitkeep
│
├── skills/                      # Reusable AI workflows
│   ├── coding-agents/SKILL.md   # Swarm orchestration skill
│   └── README.md
│
├── tools/                       # CLI tool installation
│   └── README.md                # Tool descriptions
│
└── docs/                        # Documentation
    ├── architecture.md          # System architecture
    ├── orchestration.md         # Existing docs
    ├── services.md
    ├── tooling.md
    └── multi-agent.md
```

## Core Concepts

### Beads (Work Items)

Beads are structured task records tracked by the `br` tool:

```bash
br create --title "Add user authentication" --priority 1
br list
br show <bead-id>
br update <bead-id> --status done
```

### Agent Dispatch

The `dispatch.sh` script handles the full agent lifecycle:

```bash
./scripts/dispatch.sh <bead-id> <repo-path> <agent-type> "<prompt>" [template-name]
```

**Parameters:**
- `bead-id`: Unique task identifier
- `repo-path`: Absolute path to repository
- `agent-type`: `claude` or `codex`
- `prompt`: Task instructions
- `template-name`: (optional) Template identifier

**What it does:**
1. Validates environment (preflight checks)
2. Creates tmux session on shared socket
3. Launches agent with prompt
4. Starts background watcher
5. Detects completion (status file / markers / prompt)
6. Writes run and result records
7. Runs verification
8. Cleans up session
9. Notifies coordinator

### State Tracking

All execution state is stored as JSON in `~/.openclaw/workspace/state/`:

```
state/
├── runs/<bead-id>.json      # Full execution metadata
├── results/<bead-id>.json   # Terminal status + verification
└── watch/<bead-id>.*        # Runtime files (temporary)
```

**Run record** includes:
- Agent type and model
- Timing information
- Exit codes
- Verification results
- Full prompt

**Result record** includes:
- Terminal status (done/failed/timeout)
- Reason for completion
- Retry information
- Output summary

### Monitoring

**Active agent monitoring:**
```bash
./scripts/poll-agents.sh
tmux -S /tmp/openclaw-coding-agents.sock list-sessions
```

**Service monitoring (Argus):**
- Runs every 5 minutes
- AI-powered decision making (Claude Haiku)
- Can restart services, kill orphans, send alerts
- Logs all observations

**System logs:**
```bash
journalctl -u openclaw-gateway -f
journalctl -u mcp-agent-mail -f
journalctl -u argus -f
```

## How to Use the System

### Basic Workflow

1. **Create a task (bead)**
   ```bash
   br create --title "Implement feature X" --priority 1
   ```

2. **Dispatch agent**
   ```bash
   ./scripts/dispatch.sh abc123 ~/my-project claude "$(cat swarm/templates/feature.md)"
   ```

3. **Monitor progress**
   ```bash
   ./scripts/poll-agents.sh
   ```

4. **Check results**
   ```bash
   cat state/results/abc123.json | jq
   ```

5. **Review and close**
   ```bash
   br update abc123 --status done
   ```

### Multi-Agent Workflow

The coordinator (Athena) can dispatch multiple agents in parallel:

1. **Decompose** work into independent tasks
2. **Create beads** for each task
3. **Dispatch all agents** (non-blocking)
4. **Schedule single check** after expected duration
5. **Collect results** when check runs
6. **Report back** to user

**Key principle:** Never poll in a loop. Fire and forget, with one delayed check.

### Using Templates

Templates are pre-written prompts for common task types:

```bash
PROMPT=$(cat swarm/templates/bug-fix.md)
./scripts/dispatch.sh abc123 ~/project claude "$PROMPT" bug-fix
```

Available templates:
- `feature.md` - New feature implementation
- `bug-fix.md` - Bug fixing
- `refactor.md` - Code refactoring
- `docs.md` - Documentation
- `script.md` - Script creation
- `code-review.md` - Code review

### Verification

The `verify.sh` script runs automatic quality checks:

```bash
./scripts/verify.sh ~/project abc123
```

Checks:
- Lint changed files
- Run tests (npm/cargo)
- Run bug scanner (ubs)

Results are included in the run record's `verification` field.

## Argus Ops Watchdog

Argus is an independent AI-powered monitoring service:

**What it monitors:**
- Service health (openclaw-gateway, mcp-agent-mail)
- System resources (memory, disk, CPU)
- Orphaned processes
- Agent activity
- Athena web API

**What it can do:**
- Restart failed services
- Kill stuck processes
- Send Telegram alerts
- Log observations

**How it works:**
- Runs every 5 minutes
- Collects metrics
- Sends to Claude Haiku
- LLM decides actions
- Executes allowlisted operations only

See [argus/README.md](argus/README.md) for full documentation.

## Security

**Service isolation:**
- Each systemd service runs as dedicated user
- Minimal filesystem access via systemd hardening
- No network access except required ports

**Agent sandboxing:**
- Agents run in tmux sessions (process isolation)
- Limited to specified repository paths
- No sudo/root access

**Secret management:**
- API keys in `.env` files (not in git)
- Service environment files in `/etc/` or `~/`
- Systemd `EnvironmentFile` for secure loading

**Network:**
- OpenClaw exposed only on Tailscale VPN
- Other services localhost-only
- SSH access via Tailscale

## Recommended Tools

See [tools/README.md](tools/README.md) for installation instructions.

**Core:**
- `br` / `bv` - Work tracking
- `claude` - Claude Code CLI
- `openclaw` - OpenClaw CLI
- `jq` - JSON processing
- `tmux` - Terminal multiplexer

**Optional:**
- `cass` - Agent session search
- `ntm` - Named tmux manager
- `ubs` - Bug scanner
- `rtk` - Token reduction proxy
- `dcg` - Destructive command guard

## Documentation

- **[Architecture](docs/architecture.md)** - System design and data flow
- **[Swarm System](swarm/README.md)** - Agent dispatch details
- **[Skills](skills/README.md)** - Reusable workflows
- **[Tools](tools/README.md)** - CLI tool reference
- **[Argus](argus/README.md)** - Ops watchdog documentation
- **[Multi-Agent](docs/multi-agent.md)** - Multi-agent architecture research

## Troubleshooting

**Agents won't start:**
```bash
./scripts/agent-preflight.sh claude ~/project
```

**Services not running:**
```bash
sudo systemctl status openclaw-gateway
sudo systemctl status mcp-agent-mail
journalctl -u openclaw-gateway -n 50
```

**Orphaned sessions:**
```bash
tmux -S /tmp/openclaw-coding-agents.sock list-sessions
tmux -S /tmp/openclaw-coding-agents.sock kill-session -t agent-abc123
```

**Argus issues:**
```bash
sudo journalctl -u argus -n 50
cat ~/argus/logs/argus.log
cat ~/argus/logs/last_response.json | jq
```

## Contributing

This is a template repository. To adapt for your own use:

1. Fork this repository
2. Update placeholders in service files (your-user, your-hostname)
3. Customize workspace files (SOUL.md, USER.md, TOOLS.md)
4. Add project-specific templates to `swarm/templates/`
5. Extend verification checks in `verify.sh`
6. Document your customizations

## License

MIT

---

**Build faster. Think clearer. Let the swarm handle the details.**
