#!/usr/bin/env zsh

if [[ "$OSTYPE" = darwin* ]]; then
  # macOS's $HOST changes with dhcp, etc. Use ComputerName if possible.
  SHORT_HOST=$(scutil --get ComputerName 2>/dev/null) || SHORT_HOST="${HOST/.*/}"
else
  SHORT_HOST="${HOST/.*/}"
fi

[[ -z "$XDG_CONFIG_HOME" ]] && export XDG_CONFIG_HOME="$HOME/.config"
[[ -z "$XDG_DATA_HOME" ]] && export XDG_DATA_HOME="$HOME/.local/share"
[[ -z "$XDG_CACHE_HOME" ]] && export XDG_CACHE_HOME="$HOME/.cache"
[[ -z "$XDG_DATA_DIR" ]] && export XDG_DATA_DIR="/usr/local/share:/usr/share"
[[ -z "$XDG_CONFIG_DIRS" ]] && export XDG_CONFIG_DIRS="/etc/xdg" || export XDG_CONFIG_DIRS="/etc/xdg:$XDG_CONFIG_DIRS"

# "Source" $XDG_CONFIG_HOME/user-dirs.dirs
[ -f "$XDG_CONFIG_HOME/user-dirs.dirs" ] && eval "$(sed 's/^[^#].*/export &/g;t;d' $XDG_CONFIG_HOME/user-dirs.dirs)"

if [ -d "$XDOTDIR" ]; then
  export XDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/x11"
  else
  mkdir -p "${XDG_CONFIG_HOME:-$HOME/.config}/x11"
  export XDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/x11"
fi

# zsh home
export ZDOTDIR="${XDG_CONFIG_HOME:-$HOME/.config}/zsh"
export ZCACHE=$XDG_CACHE_HOME
export ZSH_COMPDUMP="${ZCACHE:-$HOME}/.zcompdump-${SHORT_HOST}-${ZSH_VERSION}"
# histfiles
export HISTFILE="$ZCACHE/zsh_history"
# zplug
export ZPLUG_HOME="$ZDOTDIR/zplug"
# starship
export STARSHIP_CONFIG="$ZDOTDIR/starship.toml"
# Prevent the less hist file from being made, I don't want it
export LESSHISTFILE="/dev/null"


# ICEauthority
export ICEAUTHORITY=${XDG_CACHE_HOME}/ICEauthority

# xorg
# export XAUTHORITY="$XDG_RUNTIME_DIR/.Xauthority"
export XAUTHORITY="$HOME/.Xauthority"
export XINITRC="$XDOTDIR/xinitrc"
export XSTARTCMD="startxfce4"

if [[ -z "$LANG" ]]; then
  export LANG='en_US.UTF-8'
fi

export LUNARVIM_RUNTIME_DIR="${LUNARVIM_RUNTIME_DIR:-"$HOME/.local/share/lunarvim"}"
export LUNARVIM_CONFIG_DIR="${LUNARVIM_CONFIG_DIR:-"$HOME/.config/lvim"}"
export LUNARVIM_CACHE_DIR="${LUNARVIM_CACHE_DIR:-"$HOME/.cache/lvim"}"

# Text Editor
export EDITOR="lvim"
export VISUAL="$EDITOR"

export PAGER="less"
export MANPAGER="$EDITOR +Man!"

# Git
export GPG_TTY=$(tty) # Sign git commit with gpg
export GIT_EDITOR="$EDITOR"

# gnupg
export GNUPGHOME="${XDG_DATA_HOME:-$HOME/.local/share}/gnupg"

# gtk
export GTK2_RC_FILES="${XDG_CONFIG_HOME:-$HOME/.config}/gtk-2.0/gtkrc"

# rust
export CARGO_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/cargo"
export RUSTUP_HOME="${XDG_DATA_HOME:-$HOME/.local/share}/rustup"

# go
export GOPATH="${XDG_DATA_HOME:-$HOME/.local/share}/go"
export GOBIN="${XDG_DATA_HOME:-$HOME/.local/share}/go/bin"

# python
export PYTHONSTARTUP="${XDG_CONFIG_HOME:-$HOME/.config}/pythonstartup.py"

# treesitter
export TREE_SITTER_DIR="${XDG_CONFIG_HOME:-$HOME/.config}/tree-sitter"


if  [ -d "$XDG_CONFIG_HOME/wakatime" ]; then
  export WAKATIME_HOME="$XDG_CONFIG_HOME/wakatime"
else
  mkdir -p "$XDG_CONFIG_HOME/wakatime"
  export WAKATIME_HOME="$XDG_CONFIG_HOME/wakatime"
fi

# export WGETRC="${XDG_CONFIG_HOME:-$HOME/.config}/wget/wgetrc"
alias wget="wget --hsts-file $XDG_CACHE_HOME/wget-hsts"

# c/c++
export GCC_COLORS='error=01;31:warning=01;35:note=01;36:caret=01;32:locus=01:quote=01'


# set $_ZL_CMD in .bashrc/.zshrc to change the command (default z).
# set $_ZL_DATA in .bashrc/.zshrc to change the datafile (default ~/.zlua).
# set $_ZL_NO_PROMPT_COMMAND if you're handling PROMPT_COMMAND yourself.
# set $_ZL_EXCLUDE_DIRS to a comma separated list of dirs to exclude.
# set $_ZL_ADD_ONCE to '1' to update database only if $PWD changed.
# set $_ZL_MAXAGE to define a aging threshold (default is 5000).
# set $_ZL_CD to specify your own cd command (default is builtin cd in Unix shells).
# set $_ZL_ECHO to 1 to display new directory name after cd.
# set $_ZL_MATCH_MODE to 1 to enable enhanced matching.
# set $_ZL_NO_CHECK to 1 to disable path validation, use z --purge to clean
# set $_ZL_HYPHEN to 1 to treat hyphon (-) as a normal character not a lua regexp keyword.
# set $_ZL_CLINK_PROMPT_PRIORITY change clink prompt register priority (default 99).
export _ZLPATH="$ZDOTDIR/zplug/repos/skywind3000/z.lua/z.lua"
export _ZL_CMD="j"
export _ZL_DATA="$XDG_CACHE_HOME/.zlua"
export _ZL_ADD_ONCE=1
export ZSHZ_DATA="$XDG_CACHE_HOME/.z"               # change .z location from home
export ZSHZ_CASE=smart                              # case-sensitivety for z

# electron
export ELECTRUMDIR="${XDG_DATA_HOME:-$HOME/.local/share}/electrum"

# video games (proton)
export RADV_PERFTEST=aco

export RANGER_LOAD_DEFAULT_RC=FALSE

export NNN_TMPFILE=${XDG_CONFIG_HOME:-$HOME/.config}/nnn/.lastd

export LESS='-F -g -i -M -R -S -w -X -z-4'

# fzf
export FZF_DEFAULT_COMMAND='fd --type f --hidden --follow --exclude .git'

# KDE
export PLASMA_USE_QT_SCALING=1

# haskell
# export GHCUP_USE_XDG_DIRS=1
# export GHCUP_INSTALL_BASE_PREFIX="${XDG_DATA_HOME:-$HOME/.local/share}/ghcup"
export CABAL_CONFIG="${XDG_CONFIG_HOME:-$HOME/.config}/cabal/config"
export CABAL_DIR="${XDG_DATA_HOME:-$HOME/.local/share}/cabal"
export STACK_ROOT="${XDG_DATA_HOME:-$HOME/.local/share}/stack"

# path
pathmunge "$HOME/.local/bin"
pathmunge "$XDG_DATA_HOME/cargo/bin"
pathmunge "$PYENV_ROOT/bin"
pathmunge "$GOPATH/bin"
pathmunge "$PYENV_ROOT/bin"
# pathmunge "$GHCUP_INSTALL_BASE_PREFIX/bin"
pathmunge "$HOME/.ghcup/bin"
# pathmunge "$CABAL_DIR/bin"
# pathmunge "$STACK_ROOT/bin"
