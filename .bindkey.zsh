# Where should I put you?
bindkey -s ^f "tmux-sessionizer\n"
bindkey -s ^h "cd ~\n"

function zvm_vi_yank() {
	zvm_yank
	echo -n ${CUTBUFFER} | pbcopy
	zvm_exit_visual_mode
}

