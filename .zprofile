# Get OS type using uname
OS_TYPE=$(uname)

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Check if the OS is Linux or macOS
if [[ "$OS_TYPE" == "Linux" ]]; then
    # eval $(gnome-keyring-daemon --start --components=pkcs11,secrets,ssh 2>/dev/null);
    export SSH_AUTH_SOCK;
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export SSH_AUTH_SOCK;
else
    echo "The operating system is neither Linux nor macOS."
fi

export GPG_TTY=$(tty)


