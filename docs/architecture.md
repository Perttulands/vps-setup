# System Architecture

This document provides a high-level overview of the agentic coding VPS architecture.

## System Layers

```
┌─────────────────────────────────────────────────────────┐
│                     User Interface                       │
│  - Telegram (messaging)                                  │
│  - Athena Web (dashboard)                                │
│  - SSH (direct access)                                   │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   Orchestration Layer                    │
│  - OpenClaw Gateway (main coordinator)                   │
│  - Athena (AI swarm leader)                              │
│  - MCP Agent Mail (agent messaging)                      │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                      Agent Layer                         │
│  - Claude Code agents (coding)                           │
│  - Codex agents (coding)                                 │
│  - Specialized agents (future)                           │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                    Monitoring Layer                      │
│  - Argus (ops watchdog)                                  │
│  - Systemd (service management)                          │
│  - Dispatch watchers (agent monitoring)                  │
└─────────────────────────────────────────────────────────┘
                            │
                            ▼
┌─────────────────────────────────────────────────────────┐
│                   Infrastructure Layer                   │
│  - VPS (compute)                                         │
│  - Tailscale (networking)                                │
│  - Git repositories (code)                               │
│  - File system (state, logs, memory)                     │
└─────────────────────────────────────────────────────────┘
```

## Core Components

### OpenClaw Gateway
**Role:** Central orchestration hub

**Responsibilities:**
- Route messages between user and agents
- Manage agent lifecycle
- Handle authentication and permissions
- Provide MCP (Model Context Protocol) interface

**Port:** 18500
**Config:** `~/.openclaw/openclaw.json`
**Service:** `openclaw-gateway.service`

### MCP Agent Mail
**Role:** Agent-to-coordinator messaging

**Responsibilities:**
- Enable agents to signal completion with rich context
- Store message history
- Provide API for agent communication
- Support async workflows

**Port:** 8765
**Config:** `~/mcp_agent_mail/.env`
**Service:** `mcp-agent-mail.service`

### Athena Web
**Role:** Web dashboard for monitoring

**Responsibilities:**
- Display agent status
- Show memory state
- Provide quick command interface
- Visualize work items

**Port:** 9000
**Service:** `athena-web.service`

### Argus
**Role:** Independent ops watchdog

**Responsibilities:**
- Monitor system health (services, resources, processes)
- Take corrective action (restart services, kill orphans)
- Alert on critical issues
- Log observations

**Service:** `argus.service`
**Decision-making:** AI-powered (Claude Haiku)

## Data Flow

### User Request → Agent Execution

```
1. User sends message via Telegram/SSH
       ↓
2. OpenClaw Gateway receives and routes
       ↓
3. Athena (coordinator) receives message
       ↓
4. Athena decomposes work into tasks (beads)
       ↓
5. Athena dispatches agents via dispatch.sh
       ↓
6. Agents work autonomously in tmux sessions
       ↓
7. Agents signal completion via:
   - MCP Agent Mail (rich context)
   - Background watcher (guaranteed fallback)
       ↓
8. Athena collects results and reports back
       ↓
9. User receives update via Telegram/SSH
```

### Agent Lifecycle

```
dispatch.sh invoked
       ↓
Preflight checks (agent-preflight.sh)
       ↓
Create tmux session on openclaw socket
       ↓
Launch agent with prompt
       ↓
Start background watcher
       ↓
Agent works (5-30 min typical)
       ↓
Completion detected (status file / markers / prompt)
       ↓
Write run + result records
       ↓
Run verification (verify.sh)
       ↓
Clean up session
       ↓
Notify coordinator (MCP Agent Mail)
       ↓
Update memory files
```

## State Management

### File System Organization

```
~/.openclaw/workspace/
├── AGENTS.md              # Entry point
├── SOUL.md                # AI identity
├── USER.md                # User profile
├── TOOLS.md               # Server reference
├── memory/                # Daily session logs
│   └── YYYY-MM-DD.md
├── state/                 # Agent execution state
│   ├── runs/              # Full execution records
│   ├── results/           # Terminal results
│   └── watch/             # Runtime files (temp)
├── scripts/               # Dispatch system
│   ├── dispatch.sh
│   ├── verify.sh
│   ├── agent-preflight.sh
│   └── poll-agents.sh
├── templates/             # Prompt templates
│   ├── feature.md
│   ├── bug-fix.md
│   └── ...
└── skills/                # Reusable workflows
    └── coding-agents/
```

### State Records Schema

**Run record** (`state/runs/<bead>.json`):
- Full execution details
- Agent metadata (type, model)
- Timing information
- Exit codes
- Verification results

**Result record** (`state/results/<bead>.json`):
- Terminal status (done/failed/timeout)
- Reason for completion
- Retry information
- Output summary

## Security Model

### Service Isolation
- Each systemd service runs as dedicated user
- Minimal filesystem access via systemd hardening
- No network access except required ports

### Agent Sandboxing
- Agents run in tmux sessions (process isolation)
- No sudo/root access
- Limited to specified repository paths
- No arbitrary command execution (within agent's capabilities)

### Ops Watchdog Safety
- Argus can ONLY execute allowlisted actions:
  1. `restart_service` (openclaw-gateway, mcp-agent-mail)
  2. `kill_pid` (node/claude/codex processes only)
  3. `kill_tmux` (specific sessions)
  4. `alert` (Telegram notifications)
  5. `log` (write to observations.md)
- No shell command execution
- All actions require validation

### Secret Management
- API keys in `.env` files (not in git)
- Service environment files in `/etc/` or `~/`
- Systemd `EnvironmentFile` for secure loading
- No secrets in code or configs

## Network Topology

```
Internet
    │
    ▼
[Tailscale VPN]
    │
    ▼
VPS (your-tailscale-ip)
    │
    ├─ Port 18500 (openclaw-gateway) ← Tailscale only
    ├─ Port 8765 (mcp-agent-mail)    ← localhost only
    └─ Port 9000 (athena-web)        ← localhost only
```

**Security:**
- OpenClaw Gateway exposed only on Tailscale
- Other services localhost-only
- SSH access via Tailscale
- No public exposure

## Monitoring & Observability

### Systemd Logs
```bash
journalctl -u openclaw-gateway -f
journalctl -u mcp-agent-mail -f
journalctl -u athena-web -f
journalctl -u argus -f
```

### Agent Monitoring
```bash
# Active sessions
tmux -S /tmp/openclaw-coding-agents.sock list-sessions

# Attach to agent
tmux -S /tmp/openclaw-coding-agents.sock attach -t agent-<bead-id>

# Check status
./scripts/poll-agents.sh
```

### State Inspection
```bash
# Recent runs
ls -lt ~/.openclaw/workspace/state/runs/ | head

# Failed runs
jq 'select(.status == "failed")' ~/.openclaw/workspace/state/runs/*.json

# Today's memory
cat ~/.openclaw/workspace/memory/$(date +%Y-%m-%d).md
```

### Health Checks
- Argus monitors services every 5 minutes
- Automatic restart on service failure
- Alerts on resource exhaustion (>90% memory/disk)
- Orphaned process cleanup

## Scaling Considerations

### Current Limits
- ~10 concurrent agents (memory bound)
- Single VPS architecture
- No load balancing

### Scaling Options
1. **Vertical:** Upgrade VPS (more RAM, CPU)
2. **Agent pooling:** Reuse tmux sessions
3. **Distributed:** Multiple VPS nodes with shared state
4. **Resource management:** Agent quotas, priorities

## Dependencies

### Required System Packages
- `jq` - JSON processing
- `tmux` - Terminal multiplexer
- `curl` - HTTP requests
- `git` - Version control
- `node` - JavaScript runtime (athena-web)
- `systemd` - Service management

### Required CLI Tools
- `claude` - Claude Code CLI
- `codex` - Codex CLI (optional)
- `br` - Beads work tracker
- `openclaw` - OpenClaw CLI

### Optional Tools
- `cass` - Agent session search
- `ntm` - Named tmux manager
- `ubs` - Bug scanner
- `rtk` - Token reduction proxy
- `dcg` - Destructive command guard

## Future Enhancements

### Planned
- Real-time agent status dashboard
- Agent priority queues
- Resource quotas per agent type
- Cost tracking and optimization
- Agent skill library expansion

### Under Consideration
- Multi-VPS orchestration
- Agent result caching
- Automated cost optimization
- Integration with CI/CD pipelines
- Agent performance analytics

---

**Architecture: Simple, robust, scalable.**
