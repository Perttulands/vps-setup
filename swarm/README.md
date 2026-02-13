# Agent Swarm Dispatch System

This directory contains the scripts and templates for orchestrating multiple coding agents in parallel.

## Overview

The swarm system allows you to:
- Dispatch coding agents (Claude or Codex) to work on tasks autonomously
- Monitor agent progress in background tmux sessions
- Track run history and results in structured JSON
- Verify agent work with automated quality gates
- Retry failed attempts automatically

## Architecture

```
swarm/
├── scripts/          # Core dispatch and monitoring scripts
│   ├── dispatch.sh   # Main agent launcher and watcher
│   ├── verify.sh     # Post-work quality verification
│   ├── agent-preflight.sh  # Pre-launch environment checks
│   └── poll-agents.sh      # Quick status check for all active agents
└── templates/        # Prompt templates for common task types
    ├── feature.md
    ├── bug-fix.md
    ├── refactor.md
    ├── docs.md
    ├── script.md
    └── code-review.md
```

## How It Works

### 1. Agent Dispatch

`dispatch.sh` is the core orchestration script. It:
- Validates the environment and required commands
- Creates a dedicated tmux session for the agent
- Launches the agent with the prompt
- Starts a background watcher process
- Tracks execution state in JSON records

**Usage:**
```bash
./scripts/dispatch.sh <bead-id> <repo-path> <agent-type> <prompt> [template-name]
```

**Parameters:**
- `bead-id`: Unique identifier for this task (e.g., from your work tracker)
- `repo-path`: Absolute path to the repository
- `agent-type`: `claude` or `codex`
- `prompt`: The instruction for the agent
- `template-name`: (optional) Template identifier for tracking

**Example:**
```bash
./scripts/dispatch.sh abc123 ~/my-project claude "Add user authentication to the login page" feature
```

### 2. Background Monitoring

The watcher process:
- Polls the agent session every 20 seconds (configurable)
- Detects completion via status file, pane markers, or shell prompt
- Times out after 30 minutes (configurable)
- Writes final results to state files
- Cleans up orphaned sessions

### 3. State Tracking

State is stored in `~/.openclaw/workspace/state/`:

```
state/
├── runs/       # Full execution records (bead-id.json)
├── results/    # Terminal results (bead-id.json)
└── watch/      # Runtime files (cleaned up after completion)
```

**Run record** (`runs/<bead>.json`):
```json
{
  "schema_version": 1,
  "bead": "abc123",
  "agent": "claude",
  "model": "sonnet",
  "repo": "/home/user/my-project",
  "status": "done",
  "started_at": "2025-01-15T10:30:00Z",
  "finished_at": "2025-01-15T10:35:20Z",
  "duration_seconds": 320,
  "exit_code": 0,
  "attempt": 1,
  "max_retries": 2
}
```

**Result record** (`results/<bead>.json`):
```json
{
  "schema_version": 1,
  "bead": "abc123",
  "agent": "claude",
  "status": "done",
  "reason": "status-file",
  "will_retry": false,
  "duration_seconds": 320
}
```

### 4. Quality Verification

`verify.sh` runs post-work checks:
- Lints changed files
- Runs tests (npm test, cargo test)
- Runs bug scanner (ubs) if available

**Usage:**
```bash
./scripts/verify.sh <repo-path> [bead-id]
```

### 5. Preflight Checks

`agent-preflight.sh` validates the environment before launch:
- Checks required commands (jq, tmux, openclaw, claude/codex)
- Verifies CLI feature flags
- Validates repository structure
- Ensures writable paths

## Configuration

Environment variables (set before calling dispatch.sh):

```bash
export DISPATCH_MAX_RETRIES=2              # Auto-retry failed agents
export DISPATCH_WATCH_INTERVAL_SECONDS=20  # Polling frequency
export DISPATCH_WATCH_TIMEOUT_SECONDS=1800 # Max runtime (30 min)
export DISPATCH_ORPHAN_GRACE_SECONDS=600   # Grace period for cleanup
```

## Tmux Session Management

All agents run in tmux sessions on a shared socket:
- **Socket:** `/tmp/openclaw-coding-agents.sock`
- **Session naming:** `agent-<bead-id>`
- **Working directory:** Set to repo path

**Attach to an agent:**
```bash
tmux -S /tmp/openclaw-coding-agents.sock attach -t agent-abc123
```

**List all agents:**
```bash
tmux -S /tmp/openclaw-coding-agents.sock list-sessions
```

**Kill an agent manually:**
```bash
tmux -S /tmp/openclaw-coding-agents.sock kill-session -t agent-abc123
```

## Templates

Templates are pre-written prompts for common task types. They live in `templates/` and help maintain consistency.

**Available templates:**
- `feature.md` - New feature implementation
- `bug-fix.md` - Bug fixing
- `refactor.md` - Code refactoring
- `docs.md` - Documentation writing
- `script.md` - Script creation
- `code-review.md` - Code review

**Using a template:**
```bash
PROMPT=$(cat swarm/templates/feature.md)
./scripts/dispatch.sh abc123 ~/project claude "$PROMPT" feature
```

## Completion Detection

The watcher detects completion through three methods (in order of preference):

1. **Status file** (most reliable): JSON file written by the runner script
2. **Pane markers**: Special echo statements in the runner output
3. **Prompt heuristic**: Detects shell prompt via regex patterns

If the session exits without markers, it's marked as failed.

## Retry Logic

If an agent fails and `attempt < max_retries`:
- `will_retry` is set to `true` in the result
- Next dispatch increments the attempt counter
- After max retries, the result is final with `will_retry: false`

## Integration with MCP Agent Mail

Agents can signal completion via MCP Agent Mail for richer context. The dispatch system uses both:
- **Agent mail**: Rich context, optional
- **Background watcher**: Guaranteed fallback

## Monitoring Active Agents

**Quick status check:**
```bash
./scripts/poll-agents.sh
```

Output:
```
agent-abc123: RUNNING
agent-def456: DONE
Result available: ghi789
```

## Debugging

**View last LLM response:**
```bash
cat state/watch/<bead-id>.status.json | jq
```

**Check run record:**
```bash
cat state/runs/<bead-id>.json | jq
```

**Check result record:**
```bash
cat state/results/<bead-id>.json | jq
```

**View agent output:**
```bash
tmux -S /tmp/openclaw-coding-agents.sock capture-pane -t agent-<bead-id> -p
```

## Best Practices

1. **Use unique bead IDs** - Prevents conflicts and enables tracking
2. **Keep prompts focused** - One clear objective per agent
3. **Monitor from outside** - Don't poll in a loop; use single delayed checks
4. **Batch verifications** - Run verify.sh once after all agents complete
5. **Clean up state** - Periodically archive old run/result records
6. **Template everything** - Capture successful prompts as templates

## Security

- Agents run in sandboxed tmux sessions
- No network access by default (depends on agent configuration)
- State files are user-readable only
- Orphaned sessions are automatically cleaned up

## Troubleshooting

**Agent won't start:**
```bash
# Run preflight manually
./scripts/agent-preflight.sh claude ~/project
```

**Watcher not detecting completion:**
- Check that the runner script is emitting status markers
- Verify tmux socket exists and is accessible
- Check timeout settings (may need to increase)

**Sessions piling up:**
```bash
# List orphaned sessions
tmux -S /tmp/openclaw-coding-agents.sock list-sessions

# Kill specific session
tmux -S /tmp/openclaw-coding-agents.sock kill-session -t agent-abc123
```

## Extending the System

### Adding a New Agent Type

1. Update `agent-preflight.sh` to validate the new agent's CLI
2. Add agent command construction logic in `dispatch.sh`
3. Test with a simple prompt

### Adding a New Template

1. Create `templates/<name>.md`
2. Write the prompt template
3. Document it in this README

### Custom Verification

Edit `verify.sh` to add project-specific checks:
```bash
# Custom check example
if [ -f "custom-lint.sh" ]; then
    if ./custom-lint.sh; then
        CUSTOM_RESULT="pass"
    else
        CUSTOM_RESULT="fail"
        OVERALL="fail"
    fi
fi
```

---

**The swarm system: dispatch, monitor, verify, iterate.**
