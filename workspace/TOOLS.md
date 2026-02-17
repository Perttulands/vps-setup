# TOOLS.md — Local Setup

## Server

- Host: your-hostname
- User: your-user
- Tailscale IP: your-tailscale-ip

## Swarm System

All coding work flows through the swarm. Read the `coding-agents` skill for details.

```bash
bd create --title "task" --priority 1          # Create bead
./scripts/dispatch.sh <bead> <repo> codex "prompt"  # Dispatch agent
./scripts/verify.sh <bead>                     # Quality gate
bd update <bead> --status done                 # Close
```

## Services (systemd)

| Service | Port |
|---------|------|
| openclaw-gateway | 18500 |
| mcp-agent-mail | 8765 |
| athena-web | 9000 |

## CLI Tools

| Tool | Purpose |
|------|---------|
| bd | Beads — work tracking |
| bv | Beads TUI viewer |
| claude | Claude Code CLI |
| codex | Codex CLI |
| gh | GitHub CLI |
| cass | Agent session search |
| ntm | Named tmux manager |
| ubs | Bug scanner |
| rtk | Token reduction proxy (60-90% savings, auto-active via hook) |
| dcg | Destructive command guard |
| tailscale | VPN mesh |

## Agent Dispatch

- Socket: /tmp/openclaw-coding-agents.sock
- Sessions named: agent-<bead-id>
- dispatch.sh handles launch, monitoring, state tracking
- Background watcher + MCP Agent Mail for completion signals

## MCP Agent Mail

- Endpoint: http://127.0.0.1:8765/api/
- Auth: Bearer token in ~/mcp_agent_mail/.env
- Agents use this to signal completion with rich context

## Key Paths

- Workspace: ~/.openclaw/workspace/
- Scripts: ~/.openclaw/workspace/scripts/
- Templates: ~/.openclaw/workspace/templates/
- State: ~/.openclaw/workspace/state/
- Run records: ~/.openclaw/workspace/state/runs/
- Results: ~/.openclaw/workspace/state/results/
- OpenClaw config: ~/.openclaw/openclaw.json
- Agent mail: ~/mcp_agent_mail/
