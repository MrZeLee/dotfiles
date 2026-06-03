#!/usr/bin/env bash

# Toggle screen recording with wf-recorder.
#   First press : pick a region with slurp and start recording.
#   Second press: stop recording, copy the file path to the clipboard and notify.
#
# Usage: record-toggle.sh [gif]
#   gif -> after stopping, also convert the recording to a high-quality GIF.
#          The mode chosen on the *first* press is what counts.

set -euo pipefail

state="${XDG_RUNTIME_DIR:-/tmp}/wf-recorder.state"
outdir="$HOME/Videos/recordings"

# Notifications are best-effort: a missing notification daemon must never
# abort recording.
notify() { notify-send "$@" || true; }

if pgrep -x wf-recorder >/dev/null; then
  # ----- stop -----
  # shellcheck disable=SC1090
  source "$state" 2>/dev/null || true
  rm -f "$state"

  pkill -INT -x wf-recorder
  while pgrep -x wf-recorder >/dev/null; do sleep 0.1; done

  file="${FILE:-}"
  if [[ "${MODE:-mp4}" == "gif" && -f "$file" ]]; then
    gif="${file%.mp4}.gif"
    frames="$(mktemp -d)"
    ffmpeg -loglevel error -i "$file" -vf fps=20 "$frames/f%04d.png"
    gifski -o "$gif" --fps 20 --width 900 "$frames"/f*.png
    rm -rf "$frames"
    printf '%s' "$gif" | wl-copy
    notify "Recording" "GIF saved & path copied:\n$gif"
  else
    printf '%s' "$file" | wl-copy
    notify "Recording" "Saved & path copied:\n$file"
  fi
else
  # ----- start -----
  region="$(slurp -d)" || exit 0 # cancelled (Esc)
  mode="${1:-mp4}"
  mkdir -p "$outdir"
  file="$outdir/$(date +%Y-%m-%d_%H-%M-%S).mp4"
  printf 'FILE=%q\nMODE=%q\n' "$file" "$mode" >"$state"
  notify "Recording" "Started ($mode) — press the key again to stop"
  wf-recorder -g "$region" -f "$file"
fi
