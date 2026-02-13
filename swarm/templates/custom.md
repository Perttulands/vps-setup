# Custom Task

**Bead ID**: `{{BEAD_ID}}`
**Repository**: `{{REPO_PATH}}`

## Objective

{{DESCRIPTION}}

## Time Budget & Scope Constraints

⏱️ **Target completion time**: ~10 minutes
⚠️ **Alert threshold**: If approaching 20 minutes, report progress and request guidance
🛑 **Hard stop**: If task will exceed 30 minutes, **STOP and decompose into sub-tasks**

### Scope Management Rules

1. **Focus on the core objective** - Don't expand scope unless explicitly required
2. **Signal early** - If you identify blockers or complexity beyond the time budget, report immediately
3. **Prefer partial progress** - Deliver incremental value rather than attempting complete solutions beyond time budget
4. **No gold-plating** - Stick to what's needed, avoid "nice to have" additions
5. **Break down large tasks** - If scope is unclear or growing, propose decomposition

## Context Files to Read

Before starting work, identify and read relevant files:

{{FILES}}

If FILES is not specified, use `rtk git status`, file search, or code exploration to identify:
- Files mentioned in the objective
- Related modules or dependencies
- Test files for verification

## Constraints

- **Read before editing** - Understand existing code before making changes
- **Atomic commits** - One logical change per commit
- **Test your work** - Run tests after changes
- **Follow existing patterns** - Match repository conventions
- **Stay in scope** - Don't refactor unrelated code
- **Respect time budget** - Report if task is taking longer than expected

## Acceptance Criteria

Define "done" based on the objective:

- [ ] Core objective achieved
- [ ] Changes tested and verified
- [ ] Commit created with clear message
- [ ] No unrelated changes
- [ ] Completed within time budget (or decomposed if needed)

## Progress Reporting

Track your time and report status:

- **At 10 minutes**: If not complete, assess remaining work
- **At 20 minutes**: **Required checkpoint** - Report what's done, what remains, and estimated time
- **At 30 minutes**: **STOP** - Summarize progress, identify blockers, propose sub-task breakdown

### Checkpoint Format

```
Status: [IN_PROGRESS | BLOCKED | NEARLY_DONE]
Time elapsed: ~[X] minutes
Completed:
  - [What's done]
Remaining:
  - [What's left]
Estimate: [X more minutes | EXCEEDS_BUDGET - needs decomposition]
```

## Output Format

When complete (or at checkpoint), provide:

```
Task: [one-line description]
Status: [COMPLETE | PARTIAL | BLOCKED]
Time taken: ~[X] minutes
Changes:
  - [List of files modified/created]
Tests: [What was verified and how]
Commit: [commit SHA or "none" if incomplete]
Notes: [Blockers, decisions, or next steps]
```

## Test Verification

Run appropriate tests based on the repository:

```bash
# Adjust based on repo conventions
pytest              # Python
npm test            # Node.js
cargo test          # Rust
go test ./...       # Go
make test           # Makefile-based
./run_tests.sh      # Custom script
```

If tests fail, do not commit. Fix or report the failure.

## Reporting

When done (or at required checkpoint), mail Athena via MCP Agent Mail:

- **Endpoint**: `http://127.0.0.1:8765/api/send`
- **From**: `agent-{{BEAD_ID}}`
- **To**: `athena`
- **Subject**: `Custom task [COMPLETE|CHECKPOINT]: {{BEAD_ID}}`
- **Body**: Your output summary (plain text or markdown)

Send the message automatically. Do not wait for manual confirmation.

## Decomposition Trigger

If you determine the task will exceed 30 minutes, **STOP** and provide decomposition:

```
SCOPE EXCEEDED - Task requires decomposition

Original objective: [restate]
Time estimate: [X minutes]

Proposed sub-tasks:
1. [Sub-task 1] (~[Y] min)
2. [Sub-task 2] (~[Y] min)
3. [Sub-task 3] (~[Y] min)

Each sub-task can be dispatched independently with dependencies noted.

Awaiting guidance on prioritization.
```

This ensures large tasks are broken down for parallel execution or prioritized sequencing.
