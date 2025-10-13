#!/usr/bin/env bash
# Spec-Kit Plugin Validation Script
# Runs as PreToolUse hook to validate .specify/scripts paths

set -euo pipefail

# Get the plugin root directory
PLUGIN_ROOT="${CLAUDE_PLUGIN_ROOT:-$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)}"

# Parse PreToolUse hook input from stdin
INPUT=$(cat)

# Extract the bash command from tool_input
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')

# If command is empty or doesn't contain .specify/scripts, allow it (no output needed)
if [[ -z "$COMMAND" ]] || [[ ! "$COMMAND" =~ \.specify/scripts ]]; then
    exit 0
fi

# Get the project root directory
PROJECT_ROOT=$(echo "$INPUT" | jq -r '.cwd // empty')

# Check if .specify directory exists, if not, auto-install
if [[ ! -d "$PROJECT_ROOT/.specify" ]]; then
    echo ""
    echo "[INFO] .specify directory not found. Installing Spec-Kit templates..."
    echo ""

    # Run the install script
    if "${PLUGIN_ROOT}/scripts/install.sh"; then
        echo ""
        echo "[SUCCESS] Spec-Kit templates installed successfully."
        echo ""
    else
        echo ""
        echo "[ERROR] Failed to install Spec-Kit templates."
        echo "Command: $COMMAND"
        echo ""
        echo '{"permissionDecision": "deny"}'
        exit 0
    fi
fi

# Check if .specify/scripts directory exists
if [[ ! -d "$PROJECT_ROOT/.specify/scripts" ]]; then
    echo ""
    echo "[WARNING] Command references .specify/scripts but directory does not exist"
    echo "Command: $COMMAND"
    echo ""
    echo '{"permissionDecision": "ask"}'
    exit 0
fi

# Extract potential script paths from the command
# Look for patterns like .specify/scripts/bash/*.sh
SCRIPT_PATTERN='\.specify/scripts/[a-zA-Z0-9/_.-]+'

# Find all script references
SCRIPT_REFS=$(echo "$COMMAND" | grep -oE "$SCRIPT_PATTERN" || true)

if [[ -n "$SCRIPT_REFS" ]]; then
    # Check if referenced scripts exist
    MISSING_SCRIPTS=""
    while IFS= read -r SCRIPT_PATH; do
        FULL_PATH="$PROJECT_ROOT/$SCRIPT_PATH"
        if [[ ! -f "$FULL_PATH" && ! -d "$FULL_PATH" ]]; then
            MISSING_SCRIPTS="${MISSING_SCRIPTS}\n  - $SCRIPT_PATH"
        fi
    done <<< "$SCRIPT_REFS"

    if [[ -n "$MISSING_SCRIPTS" ]]; then
        echo ""
        echo "[WARNING] Command references non-existent .specify/scripts files:"
        echo -e "$MISSING_SCRIPTS"
        echo ""
        echo "Command: $COMMAND"
        echo ""
        echo '{"permissionDecision": "ask"}'
        exit 0
    fi
fi

# Allow the command (no output needed - default behavior)
exit 0