# Script Creation Task

**Bead ID**: `{{BEAD_ID}}`
**Repository**: `{{REPO_PATH}}`

## Objective

Create a standalone executable script that accomplishes the purpose described below.

## Script Purpose

{{SCRIPT_PURPOSE}}

## Output Path

Write the script to: `{{OUTPUT_PATH}}`

## Context Files to Read

Before writing the script, read these files for context or reusable patterns:

{{FILES}}

If creating a script from scratch with no dependencies, skip this step.

## Constraints

- Script must be executable (`chmod +x`)
- Include shebang line appropriate for the language
- Add usage/help text (e.g., `--help` flag or usage function)
- Handle errors gracefully (exit codes, error messages)
- Keep it self-contained — minimize external dependencies
- Use existing repo utilities if applicable (read context files first)
- Test the script manually before committing
- Do not add features beyond the stated purpose
- If the script requires changes to other files, report that instead of proceeding

## Acceptance Criteria

- [ ] Script is executable and has correct shebang
- [ ] Script runs successfully for the intended use case
- [ ] Usage/help text is clear and accurate
- [ ] Error cases are handled (exit codes, messages)
- [ ] No external dependencies unless necessary
- [ ] Commit message says "Add [script name]", not "Create script"
- [ ] No unrelated changes in the commit

## Output Format

When complete, create a summary in this format:

```
Script: [script name and path]
Purpose: [one-line description]
Usage: [how to invoke it]
Dependencies: [external tools required, if any]
Testing: [manual test command and result]
Commit: [commit SHA]
```

## Script Principles

- **Self-contained** — avoid external dependencies where possible
- **Fail fast** — use `set -euo pipefail` (bash) or equivalent
- **Clear errors** — helpful messages, non-zero exit codes
- **Help text** — always include usage instructions
- **Idempotent where applicable** — safe to run multiple times

## Testing

Before committing, test the script manually:

```bash
# Make executable
chmod +x {{OUTPUT_PATH}}

# Test help
{{OUTPUT_PATH}} --help

# Test actual usage
{{OUTPUT_PATH}} [args...]
```

If the script fails or produces incorrect output, do not commit. Fix it or report the blocker.

## Reporting

When done, mail Athena via MCP Agent Mail:

- **Endpoint**: `http://127.0.0.1:8765/api/send`
- **From**: `agent-{{BEAD_ID}}`
- **To**: `athena`
- **Subject**: `Script complete: {{BEAD_ID}}`
- **Body**: Your output summary (plain text or markdown)

Send the message automatically. Do not wait for manual confirmation.
