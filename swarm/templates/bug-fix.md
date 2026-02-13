# Bug Fix Task

**Bead ID**: `{{BEAD_ID}}`
**Repository**: `{{REPO_PATH}}`

## Objective

Fix the bug described below. Verify the fix with tests. Commit the change atomically.

## Bug Description

{{BUG_DESCRIPTION}}

## Expected Behavior

{{EXPECTED_BEHAVIOR}}

## Context Files to Read

Start by reading these files to understand the current implementation:

{{FILES}}

If the bug spans multiple modules, trace the call path by reading related files.

## Constraints

- Read affected files before making changes
- Write tests that reproduce the bug if none exist
- Run the test suite after your fix to verify no regressions
- Keep the commit atomic: one bug, one fix, one commit
- Do not refactor unrelated code
- Do not add features beyond fixing the bug
- If you discover the bug requires architectural changes, report that instead of proceeding

## Acceptance Criteria

- [ ] Bug no longer occurs under the conditions described
- [ ] Test coverage exists for the bug scenario
- [ ] All existing tests pass
- [ ] Commit message describes what was fixed, not how
- [ ] No unrelated changes in the commit

## Output Format

When complete, create a summary in this format:

```
Bug: [one-line description]
Root cause: [what caused it]
Fix: [what you changed]
Tests: [what you added/modified]
Verification: [test command and result]
Commit: [commit SHA]
```

## Test Verification

Run tests after your fix:

```bash
# Adjust based on repo conventions
pytest  # or npm test, cargo test, etc.
```

If tests fail, do not commit. Fix the failure or report the blocker.

## Reporting

When done, mail Athena via MCP Agent Mail:

- **Endpoint**: `http://127.0.0.1:8765/api/send`
- **From**: `agent-{{BEAD_ID}}`
- **To**: `athena`
- **Subject**: `Bug fix complete: {{BEAD_ID}}`
- **Body**: Your output summary (plain text or markdown)

Send the message automatically. Do not wait for manual confirmation.
