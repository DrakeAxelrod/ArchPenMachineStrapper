#! /usr/bin/env zsh

bindkey '^?' backward-delete-char        # [Backspace] - delete backward
bindkey "${terminfo[kdch1]}" delete-char # [Delete] - delete forward
bindkey "\e\e" sudo-command-line         # [Esc] [Esc] - insert "sudo" at beginning of line
zle -N sudo-command-line
sudo-command-line() {
	[[ -z $BUFFER ]] && zle up-history
	if [[ $BUFFER == sudo\ * ]]; then
		LBUFFER="${LBUFFER#sudo }"
	else
		LBUFFER="sudo $LBUFFER"
	fi
}
