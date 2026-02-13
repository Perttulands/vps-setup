# Code Review Task

**Bead ID**: `{{BEAD_ID}}`
**Repository**: `{{REPO_PATH}}`

## Objective

Perform a technical code review of the changes in this bead. Evaluate quality, correctness, and adherence to standards. Produce structured JSON output with verdict, score, issues, and patterns.

## Changed Files

{{FILES_CHANGED}}

## Diff to Review

```diff
{{DIFF}}
```

## Review Standards

You are performing a code review following Linus Torvalds-inspired quality principles:

### 1. Good Taste - Eliminate Special Cases
- Does the code handle edge cases through design, not conditional branches?
- Can any if/else logic be eliminated through better data structures?
- Are there "patches for bad design" that should be redesigned?

### 2. Simplicity - No Unnecessary Complexity
- Functions should be short and do one thing
- Maximum 3 levels of indentation
- No premature abstraction or over-engineering
- Code should be obviously correct, not cleverly correct

### 3. Correctness - It Must Work
- Logic errors, edge cases, off-by-one errors
- Error handling for all failure paths
- Resource management (leaks, cleanup)
- Null/undefined safety

### 4. Test Quality
- **CRITICAL**: Tests must import functions from production modules
- Tests must NOT define production code inline
- Functions in test files should be `test_*`, `_helper`, `pytest_*`, or fixtures
- Any other function definitions are suspicious (likely copy-pasted production code)
- Tests cover new functionality and edge cases
- Tests verify actual behavior, not mock behavior

### 5. Naming & Clarity
- Variable and function names are clear and descriptive
- No misleading or ambiguous names
- Follows repository conventions

### 6. Architecture Adherence
- Follows patterns in existing codebase
- No unnecessary new abstractions
- Data structures match the problem domain
{{#if ARCHITECTURE_RULES}}
- Adheres to rules in docs/architecture-rules.md
{{/if}}

### 7. No Unnecessary Changes
- Changes are focused on the bead's objective
- No unrelated refactoring or "improvements"
- No backwards-compatibility hacks for unused code

## Quality Checks

Perform these checks systematically:

1. **Code Correctness**: Logic, error handling, edge cases
2. **Test Coverage**: Tests exist, test real code, cover edge cases
3. **Naming**: Clear, consistent, follows conventions
4. **Complexity**: Functions are simple, no deep nesting
5. **Duplication**: No copy-paste, legitimate vs. premature abstraction
6. **Architecture**: Matches repository patterns

## Output Format

You MUST output valid JSON in exactly this format:

```json
{
  "bead": "{{BEAD_ID}}",
  "verdict": "accept|reject|revise",
  "score": 7,
  "summary": "One paragraph assessment of the change quality, approach, and overall judgment.",
  "issues": [
    {
      "severity": "critical|major|minor",
      "file": "path/to/file.py",
      "line": 42,
      "description": "What's wrong and why it matters",
      "fix": "Specific remediation action"
    }
  ],
  "patterns": [
    "Good: Used existing error handling patterns",
    "Good: Atomic commit with single responsibility"
  ],
  "reviewed_at": "{{TIMESTAMP}}"
}
```

## Verdict Guidelines

- **accept**: No critical/major issues, score >= 7, ready to merge
- **reject**: Critical issues, score < 5, requires complete rework
- **revise**: Major issues or score 5-6, fixable with targeted changes

## Severity Definitions

- **critical**: Breaks functionality, security vulnerability, data loss risk, tests that don't test real code
- **major**: Significant design flaw, missing error handling, poor architecture
- **minor**: Style inconsistency, unclear naming, minor optimization opportunity

## Scoring Rubric

- **9-10**: Excellent code, good taste evident, nothing to improve
- **7-8**: Good code, minor issues only, ready to merge
- **5-6**: Acceptable with revisions, major issues need fixing
- **3-4**: Poor quality, significant rework required
- **1-2**: Fundamentally flawed, reject and start over

## Patterns to Capture

In the `patterns` field, note what the code does WELL:
- Followed existing conventions
- Good error handling
- Clean abstractions
- Effective tests
- Smart use of language features
- Eliminated special cases

This calibration data teaches future agents what good code looks like in this repository.

## Important

- Output ONLY the JSON object, no additional text
- Be direct and specific in issue descriptions
- Provide actionable fix suggestions
- Score honestly based on the rubric
- Capture both problems AND good patterns
