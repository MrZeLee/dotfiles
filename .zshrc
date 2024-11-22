zstyle ':zim:zmodule' use 'degit'

ZIM_CONFIG_FILE=~/.config/zsh/zimrc
ZIM_HOME=~/.zim

#HISTORY
HISTFILE=~/.zsh_history
HISTSIZE=999999999
SAVEHIST=$HISTSIZE
# all instances share the same history
setopt SHARE_HISTORY
# history expansion goes into the editor buffer first
setopt HIST_VERIFY
# don't show dupes in history search
setopt HIST_FIND_NO_DUPS
# don't history commands beginning in space (consistent with bash)
setopt HIST_IGNORE_SPACE
# allow comments in the shell
setopt INTERACTIVE_COMMENTS

bindkey "^[[A" history-beginning-search-backward
bindkey "^[[B" history-beginning-search-forward

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

zvm_after_init_commands+=('[ -f $HOME/.bindkey.zsh ] && source $HOME/.bindkey.zsh')
