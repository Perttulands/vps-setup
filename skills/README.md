# Agent Skills

Skills are reusable capabilities that agents can invoke to perform complex tasks. Each skill is a modular prompt or script that encapsulates a specific workflow.

## What Are Skills?

Skills are:
- Prompt templates with structured instructions
- Reusable workflows for common tasks
- Context-aware procedures that adapt to the environment
- Documentation for how to accomplish specific goals

Skills are NOT:
- Executable code (they're prompts/documentation)
- One-time commands
- Generic how-to guides

## Available Skills

### `coding-agents/`

**Purpose:** Orchestrate multiple coding agents using the swarm dispatch system

**Key capabilities:**
- Create work items (beads) for tracking
- Dispatch agents to work on tasks autonomously
- Monitor agent progress without polling
- Verify completed work with quality gates
- Handle retries and failures gracefully

**When to use:** Any time you need to decompose work and dispatch multiple agents in parallel

**Documentation:** See `coding-agents/SKILL.md` for full details

## Using Skills

Skills are referenced in agent prompts or system instructions. For example:

```markdown
Read the `coding-agents` skill and use it to dispatch 3 agents to work on these tasks...
```

The agent will then:
1. Locate the skill file
2. Read and understand the workflow
3. Execute the steps in the skill
4. Report results

## Creating a New Skill

1. **Create a directory** for the skill in `skills/`
2. **Write a SKILL.md** file documenting:
   - Purpose and scope
   - Prerequisites
   - Step-by-step instructions
   - Examples
   - Edge cases and failure modes
3. **Test it** with an agent to ensure clarity
4. **Update this README** to list the new skill

### Skill Template

```markdown
# [Skill Name]

## Purpose
What this skill does and when to use it

## Prerequisites
- Required tools
- Required environment setup
- Required permissions

## Instructions

### Step 1: [Action]
Detailed instructions...

### Step 2: [Action]
More instructions...

## Examples

### Example 1: [Scenario]
```bash
# Commands to run
```

Expected output...

## Edge Cases
- What if X happens?
- How to handle Y?

## Verification
How to confirm the skill executed successfully
```

## Best Practices

**Keep skills focused:** One skill = one workflow. Don't create mega-skills.

**Make them self-contained:** Skills should include all necessary context.

**Use examples liberally:** Show don't tell. Examples > abstract descriptions.

**Version control:** When updating a skill, test it thoroughly first.

**Document failures:** Include troubleshooting steps for common issues.

## Skill Organization

```
skills/
├── README.md              # This file
├── coding-agents/         # Swarm orchestration
│   └── SKILL.md
├── deployment/            # Deployment workflows (future)
│   └── SKILL.md
└── debugging/             # Debugging procedures (future)
    └── SKILL.md
```

## Integration with OpenClaw

Skills can be registered with OpenClaw for discoverability:

```json
{
  "skills": [
    {
      "name": "coding-agents",
      "path": "~/.openclaw/workspace/skills/coding-agents/SKILL.md",
      "description": "Orchestrate coding agents using the swarm system"
    }
  ]
}
```

Agents can then invoke skills by name without needing the full path.

---

**Skills: Capture workflows once, use them everywhere.**
