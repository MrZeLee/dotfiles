#!/usr/bin/env bash
# Spawn a new terminal window in the same directory as the current window

# Get terminal from argument, default to wezterm
TERMINAL="${1:-wezterm}"

# Map terminal names to their window classes
get_terminal_class() {
    case "$1" in
        wezterm)
            echo "org.wezfurlong.wezterm"
            ;;
        kitty)
            echo "kitty"
            ;;
        alacritty)
            echo "Alacritty"
            ;;
        foot)
            echo "foot"
            ;;
        *)
            echo ""
            ;;
    esac
}

# Get the currently focused window info
ACTIVE_WINDOW=$(hyprctl activewindow -j 2>/dev/null)
echo "$ACTIVE_WINDOW"

# Check if we got valid window info
if [ -z "$ACTIVE_WINDOW" ] || [ "$ACTIVE_WINDOW" = "{}" ]; then
    # No active window, just spawn terminal normally
    $TERMINAL
    exit 0
fi

# Extract class and PID from the active window
WINDOW_CLASS=$(echo "$ACTIVE_WINDOW" | jq -r '.class')
WINDOW_PID=$(echo "$ACTIVE_WINDOW" | jq -r '.pid')

EXPECTED_CLASS=$(get_terminal_class "$TERMINAL")

# Check if the active window is the same terminal type
if [ -z "$EXPECTED_CLASS" ] || [ "$WINDOW_CLASS" != "$EXPECTED_CLASS" ]; then
    # Not the same terminal window, spawn normally
    $TERMINAL
    exit 0
fi

# Find the shell process running in this WezTerm window
# We need to find the deepest shell process (the one actually running commands)
find_shell_cwd() {
    local parent_pid=$1
    local shell_pid=""

    # Get all descendant processes
    local descendants=$(pstree -p "$parent_pid" | grep -oP '\(\K[0-9]+(?=\))' | tail -n +2)

    # Find the last zsh/bash/fish process (the actual interactive shell)
    for pid in $descendants; do
        if [ ! -d "/proc/$pid" ]; then
            continue
        fi

        local cmd=$(ps -o comm= -p "$pid" 2>/dev/null)
        if [[ "$cmd" =~ ^(zsh|bash|fish|sh)$ ]]; then
            shell_pid=$pid
        fi
    done

    # If we found a shell, get its cwd
    if [ -n "$shell_pid" ] && [ -d "/proc/$shell_pid" ]; then
        readlink "/proc/$shell_pid/cwd" 2>/dev/null
    fi
}

# Get the working directory of the shell
CWD=$(find_shell_cwd "$WINDOW_PID")

# Spawn terminal with cwd based on terminal type
spawn_terminal_with_cwd() {
    local terminal=$1
    local cwd=$2

    if [ -z "$cwd" ] || [ ! -d "$cwd" ]; then
        $terminal
        return
    fi

    case "$terminal" in
        wezterm)
            wezterm start --cwd "$cwd"
            ;;
        kitty)
            kitty --directory "$cwd"
            ;;
        alacritty)
            alacritty --working-directory "$cwd"
            ;;
        foot)
            foot --working-directory "$cwd"
            ;;
        *)
            # Fallback: try cd in a subshell (may not work for all terminals)
            (cd "$cwd" && $terminal)
            ;;
    esac
}

echo "$TERMINAL $CWD"

spawn_terminal_with_cwd "$TERMINAL" "$CWD"
