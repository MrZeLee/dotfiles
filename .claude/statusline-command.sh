#!/bin/sh
input=$(cat)

cwd=$(echo "$input" | jq -r '.cwd')
model=$(echo "$input" | jq -r '.model.display_name')
used=$(echo "$input" | jq -r '.context_window.used_percentage // empty')

# Shorten home directory
short_cwd=$(echo "$cwd" | sed "s|^$HOME|~|")

# Git info (skip optional locks)
branch=$(git -C "$cwd" --no-optional-locks symbolic-ref --short HEAD 2>/dev/null)
repo=$(echo "$input" | jq -r '.workspace.repo | if . then .owner + "/" + .name else empty end')

# Build git segment
git_seg=""
if [ -n "$repo" ] && [ -n "$branch" ]; then
  git_seg="${repo}:${branch}"
elif [ -n "$branch" ]; then
  git_seg="${branch}"
fi

# Build context segment
ctx_seg=""
[ -n "$used" ] && ctx_seg="ctx:$(printf '%.0f' "$used")%"

# Compose output with ANSI dim colors
RESET='\033[0m'
BOLD='\033[1m'
DIM='\033[2m'
CYAN='\033[36m'
GREEN='\033[32m'
YELLOW='\033[33m'
BLUE='\033[34m'

case "$CLAUDE_CONFIG_DIR" in
  *work*) printf '\033[1;30;42m WORK \033[0m ' ;;
  *) if [ -d "$HOME/.claude-work" ]; then bg=41; else bg=42; fi
     printf '\033[1;30;%sm PERSONAL \033[0m ' "$bg" ;;
esac
printf "${BOLD}${CYAN}%s${RESET}" "$short_cwd"
[ -n "$git_seg" ] && printf "  ${GREEN}%s${RESET}" "$git_seg"
printf "  ${DIM}${BLUE}%s${RESET}" "$model"
[ -n "$ctx_seg" ] && printf "  ${DIM}${YELLOW}%s${RESET}" "$ctx_seg"