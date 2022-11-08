#! /usr/bin/env zsh

 # order is important
ZFILES=( "functions" "env" "settings" "aliases" "keys" "plugins" "prompt" )

for ZFILE in $ZFILES
do
  source "$ZDOTDIR/$ZFILE.zsh"
done

unset ZFILES ZFILE

# check if vmware-user-suid-wrapper is not running
if [[ -z $(pgrep vmware-user-suid-wrapper) ]]; then
  # start vmware-user-suid-wrapper and redirect output to /dev/null
  vmware-user-suid-wrapper &> /dev/null &
fi
# check if imwheel is not running
if [[ -z $(pgrep imwheel) ]]; then
  # start imwheel
  imwheel -k
fi


# =============================================================================================== #
# auto run xinitrc on login
# [[ -z $DISPLAY && $XDG_VTNR -eq 1 ]] && exec startx $XINITRC
# =============================================================================================== #
