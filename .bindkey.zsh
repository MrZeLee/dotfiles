# Where should I put you?
bindkey -s ^f "tmux-sessionizer\n"
bindkey -s ^h "cd ~\n"

function zvm_vi_yank() {
	zvm_yank
	echo -n ${CUTBUFFER} | pbcopy
	zvm_exit_visual_mode
}

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
