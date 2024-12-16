zstyle ':zim:zmodule' use 'degit'

ZIM_CONFIG_FILE=~/.config/zsh/zimrc
ZIM_HOME=~/.zim

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

bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

bindkey -v
export KEYTIMEOUT=1

cursor_mode() {
    # See https://ttssh2.osdn.jp/manual/4/en/usage/tips/vim.html for cursor shapes
    cursor_block='\e[2 q'
    cursor_beam='\e[6 q'

    function zle-keymap-select {
        if [[ ${KEYMAP} == vicmd ]] ||
            [[ $1 = 'block' ]]; then
            echo -ne $cursor_block
        elif [[ ${KEYMAP} == main ]] ||
            [[ ${KEYMAP} == viins ]] ||
            [[ ${KEYMAP} = '' ]] ||
            [[ $1 = 'beam' ]]; then
            echo -ne $cursor_beam
        fi
    }

    zle-line-init() {
        echo -ne $cursor_beam
    }

    zle -N zle-keymap-select
    zle -N zle-line-init
}

cursor_mode

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

export LANG=en_US.UTF-8

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

# Only add this if you have the plugin installed
if [ -f $HOME/.config/tmux/plugins/tmux-git-autofetch/git-autofetch.tmux ]; then
    tmux-git-autofetch() {($HOME/.config/tmux/plugins/tmux-git-autofetch/git-autofetch.tmux --current &)}
    add-zsh-hook chpwd tmux-git-autofetch
fi

[ -f $HOME/.bindkey.zsh ] && source $HOME/.bindkey.zsh

# zvm_after_init_commands+=('[ -f $HOME/.bindkey.zsh ] && source $HOME/.bindkey.zsh')
