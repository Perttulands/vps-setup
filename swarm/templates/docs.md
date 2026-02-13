# Documentation Task

**Bead ID**: `{{BEAD_ID}}`
**Repository**: `{{REPO_PATH}}`

## Objective

Write or update documentation for the topic described below. Docs describe what IS, never what WAS.

## Topic

{{TOPIC}}

## Context Files to Read

Before writing docs, read these files to understand current implementation:

{{FILES}}

Identify:
- Public APIs and their signatures
- Usage patterns and examples
- Configuration options
- Error conditions
- Dependencies

## Constraints

- Read code first — docs must match reality, not assumptions
- Describe what IS, never what was changed or why
- No changelogs in the documentation files
- No "previously" or "now" comparisons
- Use present tense (e.g., "The function returns X" not "The function will return X")
- Include runnable examples where applicable
- Keep it concise — no marketing fluff
- Do not add features or change code — docs only
- If code is unclear or incorrect, report that instead of documenting broken behavior

## Acceptance Criteria

- [ ] Documentation accurately describes current behavior
- [ ] Examples are runnable and correct
- [ ] No references to previous states or changes
- [ ] Present tense throughout
- [ ] Formatted correctly (markdown, docstrings, etc.)
- [ ] Commit message says "Document [topic]", not "Add docs" or "Update README"

## Output Format

When complete, create a summary in this format:

```
Topic: [what was documented]
Files changed: [list of files]
Coverage: [what is now documented]
Examples: [number of examples added/updated]
Verification: [how you verified accuracy]
Commit: [commit SHA]
```

## Documentation Principles

- **Docs describe IS** — never "previously", "now", "changed to"
- **Examples over explanations** — show, don't tell
- **Concise and scannable** — bullet points, headers, code blocks
- **No aspirational content** — document what exists, not what's planned
- **Accuracy over completeness** — correct partial docs beat complete incorrect docs

## Verification

After writing docs:

1. Verify examples run successfully
2. Check links are valid (if applicable)
3. Ensure code snippets match actual signatures

Do not commit if examples fail or docs contradict code.

## Reporting

When done, mail Athena via MCP Agent Mail:

- **Endpoint**: `http://127.0.0.1:8765/api/send`
- **From**: `agent-{{BEAD_ID}}`
- **To**: `athena`
- **Subject**: `Docs complete: {{BEAD_ID}}`
- **Body**: Your output summary (plain text or markdown)

Send the message automatically. Do not wait for manual confirmation.
