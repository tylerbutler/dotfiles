#!/bin/sh
# Claude Code status line - mirrors Headline zsh theme layout
# user @ host: path  branch [status] | model context%

input=$(cat)

cwd=$(echo "$input" | jq -r '.workspace.current_dir // .cwd // ""')
model=$(echo "$input" | jq -r '.model.display_name // ""')
used_pct=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# ANSI colors (bold)
RED='\033[1;31m'
YELLOW='\033[1;33m'
BLUE='\033[1;34m'
CYAN='\033[1;36m'
MAGENTA='\033[1;35m'
FAINT='\033[2m'
RESET='\033[0m'

user=$(whoami)
host=$(hostname -s)

# Git branch
branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" symbolic-ref --quiet --short HEAD 2>/dev/null)
if [ -z "$branch" ]; then
  branch=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" rev-parse --short HEAD 2>/dev/null)
  [ -n "$branch" ] && branch=":$branch"
fi

# Git status symbols
git_status=''
if [ -n "$branch" ]; then
  porcelain=$(GIT_OPTIONAL_LOCKS=0 git -C "$cwd" status --porcelain -b 2>/dev/null)
  staged=$(echo "$porcelain" | grep -c '^[MTADRC] ' 2>/dev/null || echo 0)
  changed=$(echo "$porcelain" | grep -c '^ [MTADRC]' 2>/dev/null || echo 0)
  untracked=$(echo "$porcelain" | grep -c '^??' 2>/dev/null || echo 0)
  ahead=$(echo "$porcelain" | head -1 | grep -o 'ahead [0-9]*' | grep -o '[0-9]*')
  behind=$(echo "$porcelain" | head -1 | grep -o 'behind [0-9]*' | grep -o '[0-9]*')

  [ "${staged:-0}" -gt 0 ] 2>/dev/null && git_status="${git_status}+"
  [ "${changed:-0}" -gt 0 ] 2>/dev/null && git_status="${git_status}!"
  [ "${untracked:-0}" -gt 0 ] 2>/dev/null && git_status="${git_status}?"
  [ -n "$ahead" ] && git_status="${git_status}↑"
  [ -n "$behind" ] && git_status="${git_status}↓"
fi

# Context usage
context_info=''
if [ -n "$used_pct" ]; then
  used_int=$(printf '%.0f' "$used_pct" 2>/dev/null || echo "$used_pct")
  context_info=" ${used_int}%"
fi

# Build output
printf "${RED}%s${RESET}${FAINT} @ ${RESET}${YELLOW}%s${RESET}${FAINT}: ${RESET}${BLUE}%s${RESET}" \
  "$user" "$host" "$cwd"

if [ -n "$branch" ]; then
  printf "  ${CYAN}%s${RESET}" "$branch"
  if [ -n "$git_status" ]; then
    printf " ${FAINT}[${RESET}${MAGENTA}%s${RESET}${FAINT}]${RESET}" "$git_status"
  fi
fi

if [ -n "$model" ] || [ -n "$context_info" ]; then
  printf "${FAINT} | ${RESET}${FAINT}%s%s${RESET}" "$model" "$context_info"
fi

printf '\n'
