# Tooling Reference

Complete list of CLI tools and services installed on this VPS for agentic coding orchestration.

## Work Tracking

### br (Beads Rust)
- **Path**: `~/.local/bin/br`
- **Purpose**: Task/issue tracking for the flywheel
- **Key commands**:
  - `br create --title "..." --priority N` — create task (0=critical, 1=high, 2=medium, 3=low, 4=backlog)
  - `br update <id> --status done` — mark complete
  - `br list` — show all beads
  - `br show <id>` — view details

### bv (Beads Viewer)
- **Path**: `/usr/local/bin/bv`
- **Purpose**: TUI for visualizing work graph
- **Usage**: `bv` to launch interactive viewer

## Coding Agents

### claude (Claude Code CLI)
- **Path**: `/usr/local/bin/claude`
- **Purpose**: Anthropic's Claude Code agent
- **Alias**: `claude='claude --dangerously-skip-permissions'`
- **Pipe mode**: `claude -p` — read prompt from stdin, single autonomous run
- **Auth**: `claude login` required

### codex (OpenAI Codex CLI)
- **Path**: `/usr/bin/codex`
- **Purpose**: OpenAI Codex agent
- **Alias**: `codex='codex --sandbox danger-full-access'`
- **Full auto**: `codex --full-auto` — single autonomous run
- **Auth**: API key in environment

## Session Management

### ntm (Named Tmux Manager)
- **Path**: `~/.local/bin/ntm`
- **Version**: 1.7.0
- **Purpose**: Manage named tmux sessions with sockets
- **Key commands**:
  - `ntm create-socket coding` — create socket for agent sessions
  - `ntm attach coding agent-123` — attach to session
  - `ntm list coding` — list all sessions on socket
  - `ntm kill coding agent-123` — kill session

### tmux
- **Path**: `/usr/bin/tmux`
- **Purpose**: Terminal multiplexer for agent sessions
- **Usage**: Managed via `ntm` wrapper and `dispatch.sh` script

## Agent Coordination

### openclaw
- **Path**: `~/.npm-global/bin/openclaw`
- **Purpose**: Agent gateway for messaging/notifications
- **Config**: `~/.openclaw/openclaw.json`
- **Workspace**: `~/.openclaw/workspace/`
- **Service**: `openclaw-gateway.service` on port 18500

### MCP Agent Mail
- **Service port**: 8765
- **API endpoint**: `http://127.0.0.1:8765/api/`
- **Project dir**: `~/mcp_agent_mail/`
- **Purpose**: Agent-to-agent messaging and coordination
- **Auth**: Bearer token in `~/mcp_agent_mail/.env`
- **Service**: `mcp-agent-mail.service`

## Code Search & Memory

### cass (Coding Agent Session Search)
- **Path**: `~/.local/bin/cass`
- **Purpose**: Search past agent session transcripts
- **Usage**: `cass search "pattern"` — find in agent logs
- **Index**: Automatic from Claude Code/Codex session files

### cm (CASS Memory)
- **Path**: `/usr/local/bin/cm`
- **Purpose**: 3-layer agent memory system
- **Layers**:
  - Session memory (current task)
  - Project memory (repo-specific patterns)
  - Global memory (cross-project learnings)

## Quality & Safety

### ubs (Ultimate Bug Scanner)
- **Path**: `~/.local/bin/ubs`
- **Purpose**: Fast static analysis and bug detection
- **Usage**: `ubs <file-or-dir>` — scan for common issues
- **Used by**: `verify.sh` post-completion hook

### dcg (Destructive Command Guard)
- **Path**: `~/.local/bin/dcg`
- **Purpose**: Intercept and confirm dangerous shell commands
- **Usage**: Installed as shell hook, prompts before destructive ops
- **Examples**: guards `rm -rf`, `git push --force`, `DROP TABLE`

## Utilities

### slb (Simultaneous Launch Button)
- **Path**: `~/.local/bin/slb`
- **Version**: 0.1.0
- **Purpose**: Launch multiple commands in parallel tmux panes
- **Usage**: `slb cmd1 -- cmd2 -- cmd3` — spawn in grid layout

### ru (Repo Updater)
- **Path**: `~/.local/bin/ru`
- **Purpose**: Update multiple git repos in parallel
- **Usage**: `ru /path/to/repos/*` — pull latest in all

### ms (Meta Skill)
- **Path**: `~/.local/bin/ms`
- **Version**: 0.1.0
- **Purpose**: Skill/plugin manager for coding agents
- **Usage**: `ms list`, `ms install <name>`, `ms run <name>`

## Version Control & CI/CD

### gh (GitHub CLI)
- **Path**: `/usr/bin/gh`
- **Purpose**: GitHub API and operations
- **Auth**: Logged in as your-github-username
- **Usage**: `gh pr create`, `gh issue list`, `gh api repos/...`

### git
- **Path**: `/usr/bin/git`
- **Purpose**: Version control
- **Config**: Set via `git config --global user.name / user.email`
- **Worktrees**: Used for parallel agent work on independent beads

## Networking

### tailscale
- **Path**: `/usr/bin/tailscale`
- **Purpose**: VPN mesh network
- **Server IP**: your-tailscale-ip
- **Usage**: `sudo tailscale up` to connect, `tailscale status` to check

## System Tools

### jq
- **Path**: `/usr/bin/jq`
- **Purpose**: JSON parsing and manipulation
- **Usage**: Used extensively in scripts for parsing run records and state files

### curl/wget
- **Paths**: `/usr/bin/curl`, `/usr/bin/wget`
- **Purpose**: HTTP requests, downloading tools/scripts

### lsof
- **Path**: `/usr/bin/lsof`
- **Purpose**: List open files and network connections
- **Usage**: Debug port conflicts, check service status

## Tool Versions

To check installed versions:
```bash
claude --version
codex --version
openclaw --version
gh --version
br --version
ntm --version
tailscale --version
```

## Installation

All tools are installed via `setup.sh` in the vps-setup repo. Prebuilt binaries are downloaded to `~/.local/bin`, npm tools to `~/.npm-global/bin`.

## PATH Configuration

Added to `~/.bashrc` (or `~/.zshrc`):
```bash
export PATH="$HOME/.local/bin:$PATH"
export PATH="$HOME/.npm-global/bin:$PATH"

alias claude='claude --dangerously-skip-permissions'
alias codex='codex --sandbox danger-full-access'
```
