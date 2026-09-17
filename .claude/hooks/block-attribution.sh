#!/usr/bin/env bash
# PreToolUse hook: deny `git commit` commands whose message carries Claude
# attribution (Co-Authored-By: Claude / Generated with Claude Code). The
# attribution setting is off; this catches the model hand-writing it anyway.
#
# Wired in ~/.claude/settings.json as a PreToolUse hook matching "Bash".
# Receives the tool-call JSON on stdin. Exit 2 = deny (stderr shown to Claude).
set -uo pipefail

cmd="$(jq -r '.tool_input.command // empty')"
[ -n "$cmd" ] || exit 0

printf '%s' "$cmd" | grep -Eq 'git commit' || exit 0

if printf '%s' "$cmd" | grep -Eiq 'co-authored-by:.*claude|generated with.*claude code'; then
  cat >&2 <<MSG
Blocked by block-attribution hook: commit message contains Claude attribution.
Attribution is disabled in ~/.claude/settings.json — remove the
Co-Authored-By / "Generated with Claude Code" line and commit again.
MSG
  exit 2
fi

exit 0
