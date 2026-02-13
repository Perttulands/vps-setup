# Feature Implementation Task

**Bead ID**: `{{BEAD_ID}}`
**Repository**: `{{REPO_PATH}}`

## Objective

Implement the feature described below. Add tests. Ensure all tests pass. Commit atomically.

## Feature Specification

{{SPEC}}

## Context Files to Read

Before writing code, read these files to understand existing patterns:

{{FILES}}

Identify:
- Naming conventions
- Error handling patterns
- Testing structure
- Related features for consistency

## Constraints

- Read relevant files before creating new code
- Follow existing code style and patterns in the repository
- Add tests for the new functionality
- Run the full test suite after implementation
- Keep the commit atomic: one feature, one commit
- Do not refactor existing code unless required for the feature
- Do not add additional features beyond the spec
- If the feature requires changes to multiple subsystems, implement them together in one commit

## Acceptance Criteria

- [ ] Feature works as specified
- [ ] New tests cover the feature's behavior
- [ ] All existing tests pass
- [ ] Code follows repository conventions
- [ ] Commit message describes what was added, not implementation details
- [ ] No unrelated changes in the commit

## Output Format

When complete, create a summary in this format:

```
Feature: [one-line description]
Files changed: [list of files]
Tests added: [test file(s) and what they verify]
Verification: [test command and result]
Commit: [commit SHA]
```

## Test Verification

Run the test suite after implementation:

```bash
# Adjust based on repo conventions
pytest  # or npm test, cargo test, go test, etc.
```

If tests fail, do not commit. Fix the failure or report the blocker.

## Implementation Notes

- **Prefer editing existing files** over creating new ones unless the feature clearly requires new modules
- **Match existing abstractions** rather than inventing new patterns
- **Validate only at boundaries** (user input, external APIs) — trust internal code
- **Avoid premature optimization** — implement the spec, nothing more

## Reporting

When done, mail Athena via MCP Agent Mail:

- **Endpoint**: `http://127.0.0.1:8765/api/send`
- **From**: `agent-{{BEAD_ID}}`
- **To**: `athena`
- **Subject**: `Feature complete: {{BEAD_ID}}`
- **Body**: Your output summary (plain text or markdown)

Send the message automatically. Do not wait for manual confirmation.
