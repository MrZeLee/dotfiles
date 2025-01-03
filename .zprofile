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


