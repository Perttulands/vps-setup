#!/usr/bin/env bash
set -euo pipefail

SOCKET="/tmp/openclaw-coding-agents.sock"
STATE_DIR="state/results"

# Check if tmux socket exists
if [[ ! -S "$SOCKET" ]]; then
    echo "No active agents"
    exit 0
fi

# Get list of sessions
SESSIONS=$(tmux -S "$SOCKET" list-sessions -F "#{session_name}" 2>/dev/null || true)

if [[ -z "$SESSIONS" ]]; then
    echo "No active agents"
    exit 0
fi

# Check each session
while IFS= read -r session; do
    # Capture last 3 lines of the active pane
    LAST_LINES=$(tmux -S "$SOCKET" capture-pane -t "$session" -p -J -S -3 2>/dev/null || echo "")

    # Check if shell prompt is visible (looking for $, >, or % at start of line or after space)
    if echo "$LAST_LINES" | grep -qE '(^|[[:space:]])(\$|>|%)([[:space:]]|$)'; then
        echo "$session: DONE"
    else
        echo "$session: RUNNING"
    fi
done <<< "$SESSIONS"

# Check for completed results in state/results/
if [[ -d "$STATE_DIR" ]]; then
    shopt -s nullglob
    for result_file in "$STATE_DIR"/*.result; do
        [[ -e "$result_file" ]] || continue
        result_name=$(basename "$result_file" .result)
        echo "Result available: $result_name"
    done
    shopt -u nullglob
fi
