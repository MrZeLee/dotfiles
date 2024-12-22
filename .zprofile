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

  # MacPorts Installer addition on 2023-05-26_at_19:45:00: adding an appropriate PATH variable for use with MacPorts.
  if [ -d /opt/local/bin ]; then
    export PATH="$PATH:/opt/local/bin"
  fi

  if [ -d /opt/local/sbin ]; then
    export PATH="$PATH:/opt/local/sbin"
  fi

  if [ -d /$HOME/.cargo/bin ]; then
    export PATH="$PATH:$HOME/.cargo/bin"
  fi

  if [ -d $HOME/.npm-global/bin ]; then
    export PATH="$PATH:$HOME/.npm-global/bin"
  fi

  if [ -d /opt/homebrew/bin ]; then
    export PATH="$PATH:/opt/homebrew/bin"
  fi
  if [ -d /opt/homebrew/sbin ]; then
    export PATH="$PATH:/opt/homebrew/sbin"
  fi

  if [ -d $HOME/.nix-profile/bin ]; then
    export PATH="$PATH:$HOME/.nix-profile/bin"
  fi

  if [ -d /etc/profiles/per-user/$USER/bin ]; then
    export PATH="$PATH:/etc/profiles/per-user/$USER/bin"
  fi

  if [ -d /run/current-system/sw/bin ]; then
    export PATH="$PATH:/run/current-system/sw/bin"
  fi

  if [ -d /nix/var/nix/profiles/default/bin ]; then
    export PATH="$PATH:/nix/var/nix/profiles/default/bin"
  fi

  if [ -d $HOME/.local/bin ]; then
    export PATH="$PATH:$HOME/.local/bin"
  fi

  if [ -d $HOME/.config/tmux/scripts ]; then
    export PATH="$PATH:$HOME/.config/tmux/scripts"
  fi

  if [ -d /Applications/Docker.app/Contents/Resources/bin ]; then
    export PATH="$PATH:/Applications/Docker.app/Contents/Resources/bin"
  fi

  # Adding latexmk
  # TODO install latexmk after installing mactex using 'tlmgr install latexmk'
  if [ -d /Library/TeX/texbin ]; then
    export PATH="$PATH:/Library/TeX/texbin"
  fi

  # Added to enable lib in Cargo
  if [ -d $HOME/.nix-profile/lib ]; then
    export LIBRARY_PATH="$LIBRARY_PATH:$HOME/.nix-profile/lib"
  fi

  # MacPorts Installer addition on 2023-05-26_at_19:45:00: adding an appropriate MANPATH variable for use with MacPorts.
  if [ -d /opt/local/share/man ]; then
    export MANPATH="$MANPATH:/opt/local/share/man"
  fi
  # Finished adapting your MANPATH environment variable for use with MacPorts.
fi

# TMUX
export XDG_CONFIG_HOME="$HOME/.config"

alias vimv='vimv -e vim'
# Finished adapting your PATH environment variable for use with MacPorts.

#PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
#export VIM=~/.config/nvim
alias vi="nvim -c 'if filereadable(\"Session.vim\") | source Session.vim | endif'"
alias vim="nvim -c 'if filereadable(\"Session.vim\") | source Session.vim | endif'"

# # Added DBUS for vim zathura integration
# # Creates problems in the nixos login
# export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"

alias h='cd ~'
alias o='fzf -m | xargs -I % open %'
alias f='fzf | xargs -I % open -R %'
alias cl='clear'

alias ta='tmux attach'

alias c='dir=$(fzf | xargs -I {} dirname "{}") && cd "$dir"'
alias t="tree -d -L 7| grep --color="never" -E '── \d\d-'"

if command -v brew &> /dev/null; then
  alias upgrade_apps='brew upgrade --cask --no-quarantine --greedy'
fi

if [[ "$OS_TYPE" == "Darwin" ]]; then
  alias flushdns='sudo dscacheutil -flushcache; sudo killall -HUP mDNSResponder'
  alias finderhide='defaults write com.apple.finder CreateDesktop -bool false; killall Finder'
  alias findershow='defaults write com.apple.finder CreateDesktop -bool true; killall Finder'
fi

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
if command -v bat &> /dev/null; then
    alias cat='bat'
fi

if command -v automator &> /dev/null; then
  wallpaper () { automator -i "${1}" ~/.Workflows/SetWallpaper.workflow }
fi

wttr () { curl wttr.in/$1 }
cheat() { curl cheat.sh/$1 }

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
