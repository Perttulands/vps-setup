---
name: coding-agents
description: Dispatch coding agents via the swarm system. Use for all coding tasks — features, bugs, refactors, reviews.
---

# Coding Agents

All coding work goes through the swarm system. One command dispatches an agent with full lifecycle management.

## Dispatch

```bash
cd ~/.openclaw/workspace
bd create --title "Description of work" --priority 1
# → outputs bead ID like bd-32d

./scripts/dispatch.sh <bead-id> <repo-path> <agent-type> "<prompt>"
# agent-type: claude | codex
```

That's it. dispatch.sh handles:
- tmux session creation (named `agent-<bead-id>`)
- Agent launch with correct flags
- Run record in state/runs/
- Background watcher for completion detection
- Result record in state/results/

## Agent Selection

- **codex**: System work, multi-file changes, complex builds
- **claude**: Sonnet for scoped tasks, Opus for architecture

## Prompt Quality

Self-contained prompts. Include:
- What to build/fix
- Which files matter
- How to verify (test command, expected behavior)
- Constraints

Templates in `templates/` for common patterns (feature, bug-fix, refactor, docs).

## Monitoring

dispatch.sh runs a background watcher. Completion signals arrive via:
1. MCP Agent Mail (rich context from agent)
2. Background watcher → cron wake (guaranteed)

Do not poll. Wait for the signal.

For >2 agents, delegate monitoring to a `sessions_spawn` sub-agent.

## Checking Status

```bash
# All active sessions
tmux -S /tmp/openclaw-coding-agents.sock list-sessions
# Batch status
./scripts/poll-agents.sh
# One agent's output
tmux -S /tmp/openclaw-coding-agents.sock capture-pane -p -J -t "agent-<bead-id>" -S -20
```

## After Completion

```bash
./scripts/verify.sh <bead-id>    # Quality gate
bd update <bead-id> --status done  # Close
```

Failed agents get max 2 retries (fresh session each time). After 2 failures → escalate.

## Manual tmux

Only for debugging or interacting with a running agent:

```bash
SOCKET="/tmp/openclaw-coding-agents.sock"
# Attach to watch
tmux -S "$SOCKET" attach -t "agent-<bead-id>"
# Send input
tmux -S "$SOCKET" send-keys -t "agent-<bead-id>" -l -- "<text>"
tmux -S "$SOCKET" send-keys -t "agent-<bead-id>" Enter
# Kill
tmux -S "$SOCKET" kill-session -t "agent-<bead-id>"
```

## Parallel Work

Git worktrees for independent beads on the same repo:
```bash
git worktree add ../repo-wt-1 -b bead-abc
./scripts/dispatch.sh bd-abc ../repo-wt-1 claude "prompt"
```

Up to 6 simultaneous agents. Defer if RAM >90%.
