#!/bin/bash
# Claude Code Status Line - inspired by headline.zsh theme
# Read JSON input from stdin
input=$(cat)

# Extract values using jq
MODEL_DISPLAY=$(echo "$input" | jq -r '.model.display_name')
CURRENT_DIR=$(echo "$input" | jq -r '.workspace.current_dir')
USER=$(whoami)
HOST=$(hostname -s)

# Git information (skip optional locks like your zsh theme)
GIT_INFO=""
if git rev-parse --git-dir > /dev/null 2>&1; then
    BRANCH=$(GIT_OPTIONAL_LOCKS=0 git branch --show-current 2>/dev/null)
    if [ -z "$BRANCH" ]; then
        # Detached HEAD - show short hash
        BRANCH=":$(GIT_OPTIONAL_LOCKS=0 git rev-parse --short HEAD 2>/dev/null)"
    fi

    # Git status (simplified)
    STATUS=""
    if [ -n "$(GIT_OPTIONAL_LOCKS=0 git status --porcelain 2>/dev/null)" ]; then
        STATUS=" [!]"
    fi

    GIT_INFO=" | $BRANCH$STATUS"
fi

# Output format: user @ host: path | branch [status]
printf "%s @ %s: %s | %s%s\n" "$USER" "$HOST" "${CURRENT_DIR/#$HOME/~}" "$MODEL_DISPLAY" "$GIT_INFO"
