# Where should I put you?
#
# Define a zle function to run the command
tmux_sessionizer() {
  if [[ -z "$TMUX" ]]; then
    tmux new-session -n "sessionizer" -A -s asd <>$TTY "tmux-sessionizer"
  else
    tmux new-window -n "sessionizer" "tmux-sessionizer"
  fi
  zle reset-prompt
}

# Create a widget for the function
zle -N tmux_sessionizer

# Bind Ctrl-f to the new widget
bindkey '^f' tmux_sessionizer

bindkey -s ^h "cd ~\n"

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

if command -v helm &> /dev/null
then
  source <(helm completion zsh)
fi

if command -v fleet &> /dev/null
then
  source <(fleet completion zsh)
fi

if command -v eza &> /dev/null
then
  alias ls="exa --icons --classify --colour=auto --sort=type --group-directories-first --header --modified --created --git --binary --group"
  alias la="ls -a"
  alias ll="ls -al"
fi

function zvm_vi_yank() {
  zvm_yank
  echo -n ${CUTBUFFER} | ${COPY}
  zvm_exit_visual_mode
}
