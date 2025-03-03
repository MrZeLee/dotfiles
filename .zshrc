zstyle ':zim:zmodule' use 'degit'

DEDUPE_PATH="$(printf %s "$PATH" | awk -v RS=: '{ if (!arr[$0]++) {printf("%s%s",!ln++?"":":",$0)}}')"
export PATH=$DEDUPE_PATH

ZIM_CONFIG_FILE=~/.config/zsh/zimrc
ZIM_HOME=~/.zim

# Get OS type using uname
OS_TYPE=$(uname)

# Check if the OS is Linux or macOS
if [[ "$OS_TYPE" == "Linux" ]]; then
  export SSH_AUTH_SOCK="$XDG_RUNTIME_DIR/keyring/ssh"
  export OPEN="xdg-open"
  function open() {
    nohup xdg-open "$@" >/dev/null 2>&1 &!
  }
  export COPY="wl-copy"
elif [[ "$OS_TYPE" == "Darwin" ]]; then
  export OPEN="open"
  export COPY="pbcopy"
  export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"
else
  :
fi

{ tmux has-session -t main &> /dev/null || tmux new-session -d -s main; } &!

#HISTORY
HISTFILE=~/.zsh_history
HISTSIZE=999999999
SAVEHIST=$HISTSIZE

setopt SHARE_HISTORY            # all instances share the same history
setopt HIST_VERIFY              # history expansion goes into the editor buffer first
setopt HIST_FIND_NO_DUPS        # don't show dupes in history search
setopt HIST_IGNORE_SPACE        # don't history commands beginning in space (consistent with bash)
setopt INTERACTIVE_COMMENTS     # allow comments in the shell
setopt APPEND_HISTORY           # Append new history to the file, instead of overwriting it.
setopt INC_APPEND_HISTORY       # Add commands to the history file as they are executed.
setopt HIST_IGNORE_DUPS         # Avoid duplicate entries in the history file.
setopt EXTENDED_HISTORY         # Save timestamps in the history file.

bindkey -v

# enables cursor to delete characters to the left, when exiting visual mode
bindkey -M viins '^?' backward-delete-char
bindkey -M viins '^H' backward-delete-char

bindkey '^A' beginning-of-line
bindkey '^E' end-of-line

autoload -U up-line-or-beginning-search
autoload -U down-line-or-beginning-search
zle -N up-line-or-beginning-search
zle -N down-line-or-beginning-search
bindkey "^[[A" up-line-or-beginning-search # Up
bindkey "^[[B" down-line-or-beginning-search # Down

export KEYTIMEOUT=1

# cursor_mode() {
#     # See https://ttssh2.osdn.jp/manual/4/en/usage/tips/vim.html for cursor shapes
#     cursor_block='\e[2 q'
#     cursor_beam='\e[6 q'
#
#     function zle-keymap-select {
#         if [[ ${KEYMAP} == vicmd ]] ||
#             [[ $1 = 'block' ]]; then
#             echo -ne $cursor_block
#         elif [[ ${KEYMAP} == main ]] ||
#             [[ ${KEYMAP} == viins ]] ||
#             [[ ${KEYMAP} = '' ]] ||
#             [[ $1 = 'beam' ]]; then
#             echo -ne $cursor_beam
#         fi
#     }
#
#     zle-line-init() {
#         echo -ne $cursor_beam
#     }
#     # Restore cursor to default on exit
#     reset_cursor() {
#         echo -ne '\e[0 q'
#     }
#     trap reset_cursor EXIT
#
#     zle -N zle-keymap-select
#     zle -N zle-line-init
# }
#
# cursor_mode

zmodload zsh/complist
bindkey -M menuselect 'h' vi-backward-char
bindkey -M menuselect 'k' vi-up-line-or-history
bindkey -M menuselect 'l' vi-forward-char
bindkey -M menuselect 'j' vi-down-line-or-history

# Download zimfw plugin manager if missing.
if [[ ! -e ${ZIM_HOME}/zimfw.zsh ]]; then
  curl -fsSL --create-dirs -o ${ZIM_HOME}/zimfw.zsh \
    https://github.com/zimfw/zimfw/releases/latest/download/zimfw.zsh
fi

# Install missing modules and update ${ZIM_HOME}/init.zsh if missing or outdated.
if [[ ! ${ZIM_HOME}/init.zsh -nt ${ZIM_CONFIG_FILE:-${ZDOTDIR:-${HOME}}/.zimrc} ]]; then
  source ${ZIM_HOME}/zimfw.zsh init -q
fi

source ${ZIM_HOME}/init.zsh

# Enable Powerlevel10k instant prompt with quiet mode to reduce console output
typeset -g POWERLEVEL9K_INSTANT_PROMPT=quiet

# Enable Powerlevel10k instant prompt. Should stay close to the top of ~/.zshrc.
if [[ -r "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh" ]]; then
  source "${XDG_CACHE_HOME:-$HOME/.cache}/p10k-instant-prompt-${(%):-%n}.zsh"
fi

[[ ! -f ~/.p10k.zsh ]] || source ~/.p10k.zsh

# export LANG=en_US.UTF-8

# Preferred editor for local and remote sessions
if [[ -n $SSH_CONNECTION ]]; then
  export EDITOR='vim'
else
  export EDITOR='nvim'
fi

if command -v direnv &> /dev/null
then
  source <(direnv hook zsh)
fi

if command -v yazi &> /dev/null
then
  function y() {
    local tmp="$(mktemp -t "yazi-cwd.XXXXXX")" cwd
    yazi "$@" --cwd-file="$tmp"
    if cwd="$(command cat -- "$tmp")" && [ -n "$cwd" ] && [ "$cwd" != "$PWD" ]; then
      builtin cd -- "$cwd"
    fi
    rm -f -- "$tmp"
  }
fi

# Only add this if you have the plugin installed
if [ -f $HOME/.config/tmux/plugins/tmux-git-autofetch/git-autofetch.tmux ]; then
  tmux-git-autofetch() {($HOME/.config/tmux/plugins/tmux-git-autofetch/git-autofetch.tmux --current &)}
  add-zsh-hook chpwd tmux-git-autofetch
fi

# TMUX
export XDG_CONFIG_HOME="$HOME/.config"

alias cd='z'
alias copy='$COPY'
alias vimdiff='nvim -d'

alias rclone_config='rclone config reconnect GDrive: --auto-confirm; systemctl --user restart rclone@GDrive.service'

alias vimv='vimv -e nvim'
# Finished adapting your PATH environment variable for use with MacPorts.

#PATH="\$PATH:/Applications/Visual Studio Code.app/Contents/Resources/app/bin"
#export VIM=~/.config/nvim
alias vi="nvim -c 'if filereadable(\"Session.vim\") | source Session.vim | endif'"
alias vim="nvim -c 'if filereadable(\"Session.vim\") | source Session.vim | endif'"

# # Added DBUS for vim zathura integration
# # Creates problems in the nixos login
# export DBUS_SESSION_BUS_ADDRESS="unix:path=$DBUS_LAUNCHD_SESSION_BUS_SOCKET"

alias h='cd ~'
alias o="fzf -m | xargs -I % $OPEN %"
alias f="fzf | xargs -I % $OPEN -R %"
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
    [[ -f "$file" ]] && echo "== $file ==" && command cat "$file" && echo ""
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
if api_key=$(pass show api-key/open 2>/dev/null); then
  export OPENAI_API_KEY="$api_key"
fi
if api_key=$(pass show api-key/gemini 2>/dev/null); then
  export GEMINI_API_KEY="$api_key"
  export OCO_API_KEY="$api_key"
fi

if command -v zoxide &> /dev/null; then
  eval "$(zoxide init zsh)"
fi

# [ -f $HOME/.bindkey.zsh ] && source $HOME/.bindkey.zsh

zvm_after_init_commands+=('[ -f $HOME/.bindkey.zsh ] && source $HOME/.bindkey.zsh')
