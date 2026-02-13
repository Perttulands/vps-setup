# Refactoring Task

**Bead ID**: `{{BEAD_ID}}`
**Repository**: `{{REPO_PATH}}`

## Objective

Refactor the code as described below. Ensure behavior is unchanged. All tests must pass.

## Refactoring Goal

{{GOAL}}

## Scope

{{SCOPE}}

## Context Files to Read

Before refactoring, read these files to understand current structure:

{{FILES}}

Map out:
- Module boundaries
- Dependencies between files
- Test coverage
- Public vs internal APIs

## Constraints

- **All tests must pass** — refactoring changes structure, not behavior
- Read all affected files before making changes
- Run tests before refactoring (baseline)
- Run tests after refactoring (verification)
- Keep the commit atomic: one refactoring, one commit
- Do not add features or fix bugs — pure structure change only
- Do not expand scope beyond what is specified
- If you discover the refactoring requires breaking changes, report that instead of proceeding

## Acceptance Criteria

- [ ] Code structure matches the refactoring goal
- [ ] All tests pass (same results as before refactoring)
- [ ] No behavior changes (output identical for same inputs)
- [ ] Commit message describes what was restructured, not why
- [ ] No unrelated changes in the commit

## Output Format

When complete, create a summary in this format:

```
Refactoring: [one-line description]
Files changed: [list of files]
Structure before: [brief description]
Structure after: [brief description]
Tests: [test command and result]
Commit: [commit SHA]
```

## Test Verification

Run the test suite before and after refactoring:

```bash
# Before refactoring
pytest  # or npm test, cargo test, etc.

# After refactoring (same command, same results)
pytest
```

If test results differ, do not commit. Either fix the regression or report the blocker.

## Refactoring Principles

- **Minimum viable change** — only restructure what's specified, nothing more
- **No behavioral changes** — if output changes, it's not a refactoring
- **Trust tests** — if they pass, behavior is preserved
- **Avoid backwards-compatibility hacks** — if something is unused, delete it

## Reporting

When done, mail Athena via MCP Agent Mail:

- **Endpoint**: `http://127.0.0.1:8765/api/send`
- **From**: `agent-{{BEAD_ID}}`
- **To**: `athena`
- **Subject**: `Refactoring complete: {{BEAD_ID}}`
- **Body**: Your output summary (plain text or markdown)

Send the message automatically. Do not wait for manual confirmation.
