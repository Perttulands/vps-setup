# Orchestration Guide

How the agent swarm works: decompose, dispatch, verify, learn.

## The Flywheel

```
Work → Structured Records → Periodic Analysis → Improve Templates/Scripts → Better Work
```

Every task produces structured data. Periodic analysis surfaces patterns. Improvements target measured problems, not guesses.

## Principles

1. **Beads are the source of truth** — every task gets a bead, status is authoritative
2. **Fresh agents, always** — new session per task, kill when done, never reuse
3. **The prompt is the context** — self-contained instructions minimize exploration
4. **Coordinator stays thin** — delegate everything except decisions
5. **Structure over discipline** — scripts enforce process, JSON tracks state
6. **Data drives improvement** — structured records enable continuous learning

## The Flow

```
User → Coordinator → Bead → dispatch.sh → Agent → hooks → Verify → Close Bead
```

### 1. Receive & Decompose
User describes what they want. Coordinator interprets, decomposes into beads.

### 2. Create Bead
```bash
bd create --title "What needs to happen" --priority 1
```
Priority scale: 0=critical, 1=high, 2=medium, 3=low, 4=backlog.

### 3. Dispatch via Script
```bash
~/.openclaw/workspace/scripts/dispatch.sh <bead-id> <repo-path> claude "prompt from template"
```

The script handles everything:
- Creates tmux session named `agent-<bead-id>` on the `coding` socket
- Launches agent (`claude -p` or `codex --full-auto`)
- Writes run record to `~/.openclaw/workspace/state/runs/<bead-id>.json`
- Schedules delayed completion check (120s)
- On completion: captures exit status, writes to `state/results/<bead-id>.json`

Coordinator calls one command. No manual tmux, no polling loops.

### 4. Monitor (Automatic)
The dispatch script handles monitoring. Coordinator checks `state/results/` for completed runs:
```bash
cat ~/.openclaw/workspace/state/results/*.json | jq -r '.bead + ": " + .status'
```

For monitoring multiple agents at once:
```bash
~/.openclaw/workspace/scripts/poll-agents.sh
```

For >2 agents, delegate monitoring to a `sessions_spawn` sub-agent.

### 5. Verify (Hook-Driven)
Post-completion hook runs automatically via `verify.sh`:
- Lint check on changed files
- Test suite (if applicable)
- `ubs` scan for bugs
- Results written to run record

Coordinator reviews verification results, not raw output.

### 6. Handle Failure
- Max 2 retries per bead, fresh agent each time
- Each retry adjusts the prompt (more context, different approach)
- After 2 failures → bead status `failed`, escalate to user

### 7. Close
```bash
bd update <bead-id> --status done
```
Session auto-killed by dispatch script on completion.

## Bead Lifecycle

```
todo → active → done
              → blocked (needs input)
              → failed (max retries hit)
```

## Parallel Work

Git worktrees for independent beads:
```bash
git worktree add ../repo-wt-1 -b bead-abc
```

- One agent per worktree
- Up to 6 simultaneous agents
- Defer new agents if RAM >90%

Example parallel dispatch:
```bash
dispatch.sh bd-279 /path/to/repo-wt-1 claude "Fix auth bug"
dispatch.sh bd-280 /path/to/repo-wt-2 codex "Add rate limiting"
```

## Prompt Templates

Stored in `~/.openclaw/workspace/skills/coding-agents/references/prompt-templates.md`.

Templates are structured, not creative:
- **Bug fix**: file, bug description, expected behavior, test command
- **Feature**: spec, affected files, acceptance test
- **Refactor**: goal, scope, constraint (all tests must pass)
- **Review**: what to review, output file for findings

Coordinator picks template + fills variables, not freeform prompting.

## Structured State

### Run Records
**Location**: `~/.openclaw/workspace/state/runs/<bead-id>.json`

```json
{
  "bead": "bd-279",
  "agent": "claude",
  "model": "sonnet",
  "repo": "/path/to/repo",
  "prompt_hash": "abc123",
  "started_at": "2026-02-12T17:08:00Z",
  "finished_at": "2026-02-12T17:10:00Z",
  "exit_code": 0,
  "attempt": 1,
  "verification": {
    "lint": "pass",
    "tests": "pass",
    "ubs": "clean"
  },
  "coordinator_tool_calls": 1
}
```

### Results
**Location**: `~/.openclaw/workspace/state/results/<bead-id>.json`

Written by dispatch script on completion:
```json
{
  "bead": "bd-279",
  "status": "success",
  "exit_code": 0,
  "finished_at": "2026-02-12T17:10:00Z",
  "verification": {
    "lint": "pass",
    "tests": "pass",
    "ubs": "clean"
  }
}
```

### Active State
**Location**: `~/.openclaw/workspace/state/active.json`

Tracks running and pending agents:
```json
{
  "running": ["bd-279", "bd-280"],
  "pending_check": ["bd-281"]
}
```

## Scripts Reference

### dispatch.sh
**Location**: `~/.openclaw/workspace/scripts/dispatch.sh`

**Usage**: `dispatch.sh <bead-id> <repo-path> <agent-type> "<prompt>"`

**Arguments**:
- `bead-id`: Bead identifier (e.g., `bd-279`)
- `repo-path`: Absolute path to git repository
- `agent-type`: `claude` or `codex`
- `prompt`: Complete prompt string (quote if contains spaces)

**What it does**:
1. Creates tmux session `agent-<bead-id>` on `coding` socket
2. Launches agent in pipe mode (`claude -p`) or full auto (`codex --full-auto`)
3. Writes `state/runs/<bead-id>.json` with start metadata
4. Backgrounds delayed check (120s) to detect completion
5. On completion: captures exit code, runs `verify.sh`, writes `state/results/<bead-id>.json`

### poll-agents.sh
**Location**: `~/.openclaw/workspace/scripts/poll-agents.sh`

**Usage**: `poll-agents.sh`

**What it does**:
- Reads all sessions on `coding` socket via `ntm list coding`
- Reports status (running/done) for each agent session
- Single command shows all active work

### verify.sh
**Location**: `~/.openclaw/workspace/scripts/verify.sh`

**Usage**: `verify.sh <repo-path>`

**What it does**:
- Runs lint check on changed files (if applicable)
- Runs test suite (if present and runnable)
- Runs `ubs` scan for common bugs
- Returns structured JSON: `{"lint": "pass|fail", "tests": "pass|fail|skip", "ubs": "clean|warnings"}`

## Metrics & Analysis

Analysis runs weekly (heartbeat) or manually. Reads all `state/runs/*.json` files.

**Key metrics**:
- First-attempt success rate by prompt template
- Average retries by task type
- Completion time by agent type
- Context waste (Coordinator tool calls per dispatch)

**Output**: `state/flywheel-report.json` with top 3 improvement targets.

**Improvement loop**:
- Data identifies weak template → Coordinator or agent revises template
- Data identifies slow agent type → switch default for that task class
- Data identifies context waste → tighten dispatch script

## When Coordinator Does It Directly

Only when ALL true:
- Trivial (< 3 tool calls)
- No code writing
- Immediate result (status check, file read, quick lookup)

Everything else: decompose to bead, dispatch to agent.

## Session Management

### Creating Sessions
Via `dispatch.sh` only. Never create manually.

### Viewing Sessions
```bash
ntm list coding
tmux -L coding list-sessions
```

### Attaching to Session
```bash
ntm attach coding agent-bd-279
# or
tmux -L coding attach -t agent-bd-279
```

### Killing Sessions
Automatic via `dispatch.sh` on completion. Manual if needed:
```bash
ntm kill coding agent-bd-279
```

## Best Practices

1. **One bead = one discrete task** — decompose large work into small, verifiable units
2. **Self-contained prompts** — include file paths, constraints, test commands
3. **Fresh agent per attempt** — never reuse a session for a retry
4. **Let scripts handle mechanics** — don't manually manage tmux/state files
5. **Trust structured data** — read run records and results, not raw agent logs
6. **Review verification results** — hooks catch 90% of issues before human review
7. **Analyze periodically** — data surfaces improvement targets you wouldn't guess

## Debugging

### Agent not starting
- Check `state/runs/<bead-id>.json` for errors
- Verify tmux socket exists: `ls -la /tmp/tmux-$(id -u)/coding`
- Check agent auth: `claude --version`, `codex --version`

### Verification failing
- Run manually: `~/.openclaw/workspace/scripts/verify.sh /path/to/repo`
- Check individual tools: `ubs <file>`, test runner directly

### Script errors
- Read dispatch script: `cat ~/.openclaw/workspace/scripts/dispatch.sh`
- Check logs in `state/runs/` and `state/results/`

### Missing state files
- Scripts create directories automatically
- If missing: `mkdir -p ~/.openclaw/workspace/state/{runs,results}`
