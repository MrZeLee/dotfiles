# Get OS type using uname
OS_TYPE=$(uname)

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Check if the OS is Linux or macOS
if [[ "$OS_TYPE" == "Linux" ]]; then
    test -e "/home/linuxbrew/.linuxbrew/bin/brew" && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
else
    echo "The operating system is neither Linux nor macOS."
fi

# export LC_ALL="en_US.UTF-8"

# MacPorts Installer addition on 2023-05-26_at_19:45:00: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/.npm-global/bin:$PATH"

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/Users/$USER/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"

# Adding latexmk
# TODO install latexmk after installing mactex using 'tlmgr install latexmk'
export PATH="/Library/TeX/texbin:$PATH"

# TMUX
export XDG_CONFIG_HOME="$HOME/.config"

alias vimv='vimv -e vim'
# Finished adapting your PATH environment variable for use with MacPorts.

# MacPorts Installer addition on 2023-05-26_at_19:45:00: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH="/opt/local/share/man:$MANPATH"
# Finished adapting your MANPATH environment variable for use with MacPorts.

test -e "${HOME}/.iterm2_shell_integration.zsh" && source "${HOME}/.iterm2_shell_integration.zsh"

#PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
#export VIM=~/.config/nvim
alias vi="nvim -c 'if filereadable(\"Session.vim\") | source Session.vim | endif'"
alias vim="nvim -c 'if filereadable(\"Session.vim\") | source Session.vim | endif'"

PATH=$PATH:/Users/$USER/.local/bin

# Added DBUS for vim zathura integration
export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"

alias h='cd ~'
alias o='fzf -m | xargs -I % open %'
alias f='fzf | xargs -I % open -R %'
alias ta='tmux attach'
alias c='dir=$(fzf | xargs -I {} dirname "{}") && cd "$dir"'
alias t="tree -d -L 7| grep --color="never" -E '── \d\d-'"
#alias c='echo `fzf | xargs -I % dirname "%"`'
alias upgrade_apps='brew upgrade --cask --no-quarantine --greedy'
alias downloads='cd ~/Downloads'
alias cl='clear'
# alias dump_all='find . -type f | while read file; do echo "== $file =="; cat "$file"; echo ""; done'
alias dump_all='find . -type d -name .git -prune -o -type f -print | while read file; do echo "== $file =="; cat "$file"; echo ""; done'

function dump_files() {
    for file in "$@"; do
        [[ -f "$file" ]] && echo "== $file ==" && /bin/cat "$file" && echo ""
    done
}

# check if bat is installed
if command -v bat &> /dev/null
then
    alias cat='bat'
fi

if type "brew" > /dev/null; then
    if [ -f $(brew --prefix)/share/google-cloud-sdk/path.zsh.inc ]; then
        source "$(brew --prefix)/share/google-cloud-sdk/path.zsh.inc"
    fi
    if [ -f $(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc ]; then
        source "$(brew --prefix)/share/google-cloud-sdk/completion.zsh.inc"
    fi
fi

if command -v fzf &> /dev/null
then
    # Set up fzf key bindings and fuzzy completion
    source <(fzf --zsh)
fi

if kubectl -v brew &> /dev/null
then
    source <(kubectl completion zsh)
fi

# Work around to start tmux
# Check if tmux is running, and start it in daemon mode if it is not
if ! (pgrep -U $UID -x "tmux" > /dev/null || pgrep -U $UID -x "tmux: server" > /dev/null) ; then
    # Start tmux server in the background (daemon mode)
    tmux start-server
    # Start tmux session in detached mode if not running
    tmux new-session -d -s default
fi

zvm_after_init_commands+=('[ -f $HOME/.bindkey.zsh ] && source $HOME/.bindkey.zsh')
