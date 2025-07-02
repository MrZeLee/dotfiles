#!/usr/bin/env bash
#
# toggle-device.sh — Toggle a Hyprland input device by name,
#                  tracking state in /tmp/<device>.state
#
# Usage: toggle-device.sh "<device-name>"
# Example: toggle-device.sh "apple-spi-trackpad"

DEVICE="$1"
if [ -z "$DEVICE" ]; then
  echo "Usage: $0 <device-name>"
  exit 1
fi

# Sanitize DEVICE for filename (replace spaces/slashes with _)
SAFE_NAME="${DEVICE//[ \/]/_}"
STATE_FILE="/tmp/${SAFE_NAME}.state"

# If no state file, assume it's currently enabled
if [ ! -f "$STATE_FILE" ]; then
  CURRENT_STATE="enabled"
else
  read -r CURRENT_STATE < "$STATE_FILE"
fi

# Decide new state
if [ "$CURRENT_STATE" = "enabled" ]; then
  NEW_STATE="disabled"
  NEW_BOOL="false"
else
  NEW_STATE="enabled"
  NEW_BOOL="true"
fi

# Apply the toggle
hyprctl keyword "device[$DEVICE]:enabled" "$NEW_BOOL"

# Persist new state
echo "$NEW_STATE" > "$STATE_FILE"

# On-screen feedback
hyprctl notify -1 2000 "0" \
  "Device '$DEVICE' is now $NEW_STATE"

