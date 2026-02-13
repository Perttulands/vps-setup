# Prompt Templates

Reusable prompt templates for coding agent tasks. Each template is a structured prompt that gets variable substitution before dispatch.

## How Templates Work

1. **Select template** based on task type (bug-fix, feature, refactor, docs, script)
2. **Fill variables** using dispatch wrapper or manually
3. **Send to agent** via `dispatch.sh`

## Variables

Templates use double-brace syntax for substitution:

- `{{BEAD_ID}}` - Bead identifier (e.g., `bd-xyz`)
- `{{REPO_PATH}}` - Absolute path to repository or worktree
- `{{FILES}}` - Comma-separated list of files to focus on
- `{{DESCRIPTION}}` - Human description of the task
- `{{BUG_DESCRIPTION}}` - Specific bug details (bug-fix only)
- `{{EXPECTED_BEHAVIOR}}` - What should happen instead (bug-fix only)
- `{{SPEC}}` - Feature specification (feature only)
- `{{GOAL}}` - Refactoring objective (refactor only)
- `{{SCOPE}}` - Boundary of refactoring (refactor only)
- `{{TOPIC}}` - Documentation topic (docs only)
- `{{SCRIPT_PURPOSE}}` - What the script should do (script only)
- `{{OUTPUT_PATH}}` - Where to write the script (script only)
- `{{DESCRIPTION}}` - General task description (custom only)

## Usage Example

```bash
# Manual substitution
PROMPT=$(cat templates/bug-fix.md | \
  sed "s/{{BEAD_ID}}/bd-abc/g" | \
  sed "s|{{REPO_PATH}}|/path/to/repo|g" | \
  sed "s/{{FILES}}/src\/api.py/g" | \
  sed "s/{{BUG_DESCRIPTION}}/Crashes on empty input/g" | \
  sed "s/{{EXPECTED_BEHAVIOR}}/Should return empty list/g")

./scripts/dispatch.sh bd-abc /path/to/repo claude "$PROMPT"
```

## Template Selection

- **bug-fix.md** - Fix existing broken behavior
- **feature.md** - Add new functionality
- **refactor.md** - Improve code structure without changing behavior
- **docs.md** - Write or update documentation
- **script.md** - Create standalone executable script
- **custom.md** - General-purpose tasks with time budgets and scope constraints
- **code-review.md** - Structured code quality reviews

## Reporting Results

All templates include a final step to mail Athena via MCP Agent Mail when complete:

- **Endpoint**: `http://127.0.0.1:8765/api/send`
- **From**: `agent-{{BEAD_ID}}`
- **To**: `athena`

The agent summarizes what was done and sends it automatically when the task completes.

## Template Anatomy

Every template has these sections:

1. **Objective** - What the agent must accomplish
2. **Context Files to Read** - Which files to examine first
3. **Constraints** - Hard rules and boundaries
4. **Acceptance Criteria** - Definition of done
5. **Output Format** - How to structure results
6. **Reporting** - How to notify Athena

Templates encode lessons learned: read before editing, test after changes, keep commits atomic, report structured results.

## Principles

- **Concise, high-signal** - No fluff or motivational text
- **Self-contained** - Agent has everything needed in the prompt
- **Docs describe IS** - Never reference what was changed
- **Structure over discipline** - Clear sections, explicit constraints
- **Fresh agent assumption** - No prior context, all context in prompt
