#!/usr/bin/env bash
# Feeds wl-kbptr a keyboard-shaped 10x4 grid over the focused monitor: one key
# picks a cell (1 top-left ... / bottom-right), then hjkl halves it down.
# Labels and modes live in ~/.config/wl-kbptr/config.
set -euo pipefail

read -r name w h scale < <(
    hyprctl -j monitors |
        jq -r '.[] | select(.focused) | "\(.name) \(.width) \(.height) \(.scale)"'
)

awk -v w="$w" -v h="$h" -v s="$scale" 'BEGIN {
    cols = 10; rows = 4
    W = int(w / s); H = int(h / s)
    for (j = 0; j < rows; j++)
        for (i = 0; i < cols; i++)
            printf "%dx%d+%d+%d\n", W/cols, H/rows, i*W/cols, j*H/rows
}' | wl-kbptr -O "$name" "$@"