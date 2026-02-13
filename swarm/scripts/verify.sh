#!/bin/bash
set -euo pipefail

# Usage: verify.sh <repo-path> [bead-id]
# Runs verification checks on a repo after agent work

if [ $# -lt 1 ]; then
    echo "Usage: $0 <repo-path> [bead-id]" >&2
    exit 1
fi

REPO_PATH="$1"
BEAD_ID="${2:-}"

if [ ! -d "$REPO_PATH" ]; then
    echo "Error: Repository path does not exist: $REPO_PATH" >&2
    exit 1
fi

SCRIPT_DIR="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"

# Initialize result object
LINT_RESULT="skipped"
TESTS_RESULT="skipped"
UBS_RESULT="skipped"
LINT_DETAILS="null"
OVERALL="pass"

# Check 1: Run lint-agent.sh on changed files
cd "$REPO_PATH"
if git rev-parse --git-dir > /dev/null 2>&1; then
    CHANGED_FILES=$(git diff --name-only HEAD 2>/dev/null || true)
    if [ -n "$CHANGED_FILES" ] && [ -x "$SCRIPT_DIR/lint-agent.sh" ]; then
        LINT_OUTPUT=""
        for file in $CHANGED_FILES; do
            if [ -f "$file" ]; then
                if LINT_OUTPUT=$("$SCRIPT_DIR/lint-agent.sh" --json "$file" 2>&1); then
                    if [ "$LINT_RESULT" != "fail" ]; then
                        LINT_RESULT="pass"
                    fi
                else
                    LINT_RESULT="fail"
                    OVERALL="fail"
                    # Append lint details
                    if [ "$LINT_DETAILS" = "null" ]; then
                        LINT_DETAILS="$LINT_OUTPUT"
                    else
                        LINT_DETAILS=$(echo "$LINT_DETAILS" "$LINT_OUTPUT" | jq -s 'add')
                    fi
                fi
            fi
        done
    fi
fi

# Check 2: Run tests if package.json or Cargo.toml exists
if [ -f "package.json" ]; then
    if npm test > /dev/null 2>&1; then
        TESTS_RESULT="pass"
    else
        TESTS_RESULT="fail"
        OVERALL="fail"
    fi
elif [ -f "Cargo.toml" ]; then
    if cargo test > /dev/null 2>&1; then
        TESTS_RESULT="pass"
    else
        TESTS_RESULT="fail"
        OVERALL="fail"
    fi
fi

# Check 3: Run ubs if available
if command -v ubs > /dev/null 2>&1; then
    if ubs "$REPO_PATH" > /dev/null 2>&1; then
        UBS_RESULT="clean"
    else
        UBS_RESULT="issues"
        OVERALL="fail"
    fi
fi

# Build JSON output
JSON_OUTPUT=$(jq -n \
    --arg repo "$REPO_PATH" \
    --arg bead "$BEAD_ID" \
    --arg lint "$LINT_RESULT" \
    --arg tests "$TESTS_RESULT" \
    --arg ubs "$UBS_RESULT" \
    --argjson lint_details "$LINT_DETAILS" \
    --arg overall "$OVERALL" \
    '{
        repo: $repo,
        bead: $bead,
        checks: {
            lint: $lint,
            tests: $tests,
            ubs: $ubs,
            lint_details: $lint_details
        },
        overall: $overall
    }')

# Output to stdout
echo "$JSON_OUTPUT"

# If bead-id provided, write to state/results/<bead-id>-verify.json
if [ -n "$BEAD_ID" ]; then
    RESULTS_DIR="$SCRIPT_DIR/../state/results"
    mkdir -p "$RESULTS_DIR"
    echo "$JSON_OUTPUT" > "$RESULTS_DIR/${BEAD_ID}-verify.json"
fi
