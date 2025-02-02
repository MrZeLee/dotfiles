#!/usr/bin/env bash

WAYBAR_CMD="waybar -c $HOME/.config/waybar/${HYPRLAND_HOST}_config.jsonc"

if pgrep -fx "$WAYBAR_CMD" >/dev/null; then
    # Waybar is running, so kill it
    pkill -fx "$WAYBAR_CMD"
else
    # Waybar is not running, so launch it
    $WAYBAR_CMD &
fi
