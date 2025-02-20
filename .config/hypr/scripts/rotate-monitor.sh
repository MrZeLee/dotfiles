#!/usr/bin/env bash

CACHE_FILE="/tmp/hypr_monitor_config.json"
NO_CACHE=0

# Parse command line arguments
while [[ $# -gt 0 ]]; do
    case $1 in
        --no-cache)
            NO_CACHE=1
            shift
            ;;
        clockwise|counter-clockwise)
            direction=$1
            shift
            ;;
        *)
            echo "Unknown option: $1"
            echo "Usage: $0 [--no-cache] [clockwise|counter-clockwise]"
            exit 1
            ;;
    esac
done

# Set default direction if not specified
direction=${direction:-"clockwise"}

# Function to parse hyprland.conf and create cache
create_cache() {
    local config_file="$HOME/.config/hypr/hyprland/hosts/$HYPRLAND_HOST.conf"
    if [ ! -f "$config_file" ]; then
        echo "Error: hyprland.conf not found at $config_file"
        exit 1
      fi

    # Initialize JSON structure
    echo "{}" > "$CACHE_FILE"

    # Parse all monitor entries and store in JSON
    while IFS= read -r line; do
        if [[ $line =~ ^monitor=desc:([^,]+),(.*) ]]; then
            # Monitor with description
            description="${BASH_REMATCH[1]}"
            config="${BASH_REMATCH[2]}"
            jq --arg desc "$description" --arg conf "$config" \
               '. + {($desc): $conf}' "$CACHE_FILE" > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"
        elif [[ $line =~ ^monitor=,(.*) ]]; then
            # Default monitor
            config="${BASH_REMATCH[1]}"
            jq --arg conf "$config" \
               '. + {"DEFAULT": $conf}' "$CACHE_FILE" > "$CACHE_FILE.tmp" && mv "$CACHE_FILE.tmp" "$CACHE_FILE"
        fi
    done < <(grep "^monitor=" "$config_file")
}

# Create cache if it doesn't exist or if --no-cache is used
if [ ! -f "$CACHE_FILE" ] || [ $NO_CACHE -eq 1 ]; then
    create_cache
fi

# Get the monitor for this workspace
monitor=$(hyprctl activeworkspace -j | jq --raw-output '.monitor')
if [ -z "$monitor" ]; then
    echo "No active Monitor found."
    exit 1
fi

# Get current transform and description for the monitor
current_transform=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | .transform")
monitor_desc=$(hyprctl monitors -j | jq -r ".[] | select(.name == \"$monitor\") | .description")

# Get monitor config from cache
if [ -n "$monitor_desc" ]; then
    monitor_config=$(jq -r --arg desc "$monitor_desc" '.[$desc] // .DEFAULT // "preferred,auto,1"' "$CACHE_FILE")
else
    monitor_config=$(jq -r '.DEFAULT // "preferred,auto,1"' "$CACHE_FILE")
fi

# Function to restart wallpaper daemon
restart_wallpaper() {
    swww kill &> /dev/null
    swww-daemon &> /dev/null &!
}

# Calculate new transform
if [ "$direction" = "clockwise" ]; then
    # Clockwise rotation (0->1->2->3->0)
    new_transform=$((current_transform - 1))
    if [ $new_transform -lt 0 ]; then
        new_transform=3
    fi
else
    # Counter-clockwise rotation (0->3->2->1->0)
    new_transform=$((current_transform + 1))
    if [ $new_transform -gt 3 ]; then
        new_transform=0
    fi
fi

# Replace or append transform in monitor config, handling spaces around commas
if echo "$monitor_config" | grep -q "transform[[:space:]]*,[[:space:]]*[0-9]"; then
    monitor_config=$(echo "$monitor_config" | sed 's/transform[[:space:]]*,[[:space:]]*[0-9]/transform,'$new_transform'/')
else
    monitor_config="$monitor_config,transform,$new_transform"
fi

# Apply the transform with all original settings
hyprctl keyword monitor "$monitor,$monitor_config" -q

# Restart wallpaper daemon
restart_wallpaper
