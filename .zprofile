# Get OS type using uname
OS_TYPE=$(uname)

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Check if the OS is Linux or macOS
if [[ "$OS_TYPE" == "Linux" ]]; then
    export PINENTRY_PROGRAM="$(which pinentry)"
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PINENTRY_PROGRAM="$(which pinentry-mac)"
else
    echo "The operating system is neither Linux nor macOS."
fi

export GPG_TTY=$(tty)

if [ -z "$TMUX" ]; then

  # Function to add a directory to an environment variable if it isn't already included
  add_to_env_var() {
    local env_var_name=$1
    local dir=$2
    local current_value
    eval "current_value=\$$env_var_name"

    case ":$current_value:" in
      *":$dir:"*) ;;
      *) eval "export $env_var_name=\"$current_value:$dir\"" ;;
    esac
  }

  # Adding directories to PATH
  [ -d /opt/local/bin ] && add_to_env_var PATH "/opt/local/bin"
  [ -d /opt/local/sbin ] && add_to_env_var PATH "/opt/local/sbin"
  [ -d "$HOME/.cargo/bin" ] && add_to_env_var PATH "$HOME/.cargo/bin"
  [ -d "$HOME/.npm-global/bin" ] && add_to_env_var PATH "$HOME/.npm-global/bin"
  [ -d /opt/homebrew/bin ] && add_to_env_var PATH "/opt/homebrew/bin"
  [ -d /opt/homebrew/sbin ] && add_to_env_var PATH "/opt/homebrew/sbin"
  [ -d "$HOME/.nix-profile/bin" ] && add_to_env_var PATH "$HOME/.nix-profile/bin"
  [ -d "/etc/profiles/per-user/$USER/bin" ] && add_to_env_var PATH "/etc/profiles/per-user/$USER/bin"
  [ -d /run/current-system/sw/bin ] && add_to_env_var PATH "/run/current-system/sw/bin"
  [ -d /nix/var/nix/profiles/default/bin ] && add_to_env_var PATH "/nix/var/nix/profiles/default/bin"
  [ -d "$HOME/.local/bin" ] && add_to_env_var PATH "$HOME/.local/bin"
  [ -d "$HOME/.config/tmux/scripts" ] && add_to_env_var PATH "$HOME/.config/tmux/scripts"
  [ -d /Applications/Docker.app/Contents/Resources/bin ] && add_to_env_var PATH "/Applications/Docker.app/Contents/Resources/bin"
  [ -d /Library/TeX/texbin ] && add_to_env_var PATH "/Library/TeX/texbin"

  # Adding directories to LIBRARY_PATH
  [ -d "$HOME/.nix-profile/lib" ] && add_to_env_var LIBRARY_PATH "$HOME/.nix-profile/lib"

  # Adding directories to MANPATH
  [ -d /opt/local/share/man ] && add_to_env_var MANPATH "/opt/local/share/man"

fi

