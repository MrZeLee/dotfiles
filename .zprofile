# Get OS type using uname
OS_TYPE=$(uname)

if [ -e $HOME/.nix-profile/etc/profile.d/nix.sh ]; then . $HOME/.nix-profile/etc/profile.d/nix.sh; fi # added by Nix installer

# Check if the OS is Linux or macOS
if [[ "$OS_TYPE" == "Linux" ]]; then
    test -e "/home/linuxbrew/.linuxbrew/bin/brew" && eval "$(/home/linuxbrew/.linuxbrew/bin/brew shellenv)"
    export PINENTRY_PROGRAM="$(which pinentry)"
elif [[ "$OS_TYPE" == "Darwin" ]]; then
    eval "$(/opt/homebrew/bin/brew shellenv)"
    export PINENTRY_PROGRAM="$(which pinentry-mac)"
else
    echo "The operating system is neither Linux nor macOS."
fi

export GPG_TTY=$(tty)

# MacPorts Installer addition on 2023-05-26_at_19:45:00: adding an appropriate PATH variable for use with MacPorts.
export PATH="/opt/local/bin:/opt/local/sbin:$PATH"

export PATH="$HOME/.cargo/bin:$PATH"

export PATH="$HOME/.local/bin:$PATH"

export PATH="$HOME/.npm-global/bin:$PATH"

export PATH="/opt/homebrew/bin:/opt/homebrew/sbin:/Users/$USER/.nix-profile/bin:/etc/profiles/per-user/$USER/bin:/run/current-system/sw/bin:/nix/var/nix/profiles/default/bin:$PATH"

export PATH=$PATH:/Users/$USER/.local/bin

# Adding latexmk
# TODO install latexmk after installing mactex using 'tlmgr install latexmk'
export PATH="/Library/TeX/texbin:$PATH"

# Added to enable lib in Cargo
export LIBRARY_PATH="$HOME/.nix-profile/lib:$LIBRARY_PATH"

# MacPorts Installer addition on 2023-05-26_at_19:45:00: adding an appropriate MANPATH variable for use with MacPorts.
export MANPATH="/opt/local/share/man:$MANPATH"
# Finished adapting your MANPATH environment variable for use with MacPorts.

# TMUX
export XDG_CONFIG_HOME="$HOME/.config"

alias vimv='vimv -e vim'
# Finished adapting your PATH environment variable for use with MacPorts.

#PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
#export VIM=~/.config/nvim
alias vi="nvim -c 'if filereadable(\"Session.vim\") | source Session.vim | endif'"
alias vim="nvim -c 'if filereadable(\"Session.vim\") | source Session.vim | endif'"

# Added DBUS for vim zathura integration
export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"

alias h='cd ~'
alias o='fzf -m | xargs -I % open %'
alias f='fzf | xargs -I % open -R %'
alias cl='clear'

alias ta='tmux attach'

alias c='dir=$(fzf | xargs -I {} dirname "{}") && cd "$dir"'
alias t="tree -d -L 7| grep --color="never" -E '── \d\d-'"

alias upgrade_apps='brew upgrade --cask --no-quarantine --greedy'

alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
alias finderhide='defaults write com.apple.finder CreateDesktop -bool false; killall Finder'
alias findershow='defaults write com.apple.finder CreateDesktop -bool true; killall Finder'

alias passg='pass generate'
alias passc='pass edit'

alias ga='git commit --amend'

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

_fzf_complete_pass() {
  _fzf_complete +m -- "$@" < <(
    local prefix
    prefix="${PASSWORD_STORE_DIR:-$HOME/.password-store}"
    command find -L "$prefix" \
      -name "*.gpg" -type f | \
      sed -e "s#${prefix}/\{0,1\}##" -e 's#\.gpg##' -e 's#\\#\\\\#' | sort
  )
}

# Check if the `pass` command successfully retrieves the API key
if api_key=$(pass show api-key/anthropic 2>/dev/null); then
    export ANTHROPIC_API_KEY="$api_key"
fi
if api_key=$(pass show api-key/oco 2>/dev/null); then
    export OCO_API_KEY="$api_key"
fi
