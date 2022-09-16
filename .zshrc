#! /usr/bin/env zsh

ZFILES=( # order is important
  "functions"
  "env"
  "settings"
  "aliases"
  "keys"
  "plugins"
  "prompt"
)
for ZFILE in $ZFILES
do
  source "$ZDOTDIR/$ZFILE.zsh"
done

unset ZFILES ZFILE

# =============================================================================================== #
# auto run xinitrc on login
# [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx $XINITRC
# =============================================================================================== #
