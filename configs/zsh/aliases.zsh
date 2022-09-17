#!/usr/bin/env zsh

#  Global Aliases

# // # This is where zsh has an advantage.
# You can declare an alias as a ‘global’ alias,
# and then will be replaced anywhere in the command line:
# example:
# alias -g badge='tput bel'
# sudo badge        #<beeps> with privilege

# Suffix Aliases

# Suffix aliases take effect on the last part of a path, so usually the file extension.
# A suffix alias will assign a command to use when you just type a file path in the command line.
# example:
# alias -s txt="open -t"
# When you then type a path ending with .txt and no command,
# zsh will execute open -t /path/to/file.txt.


# startx
alias startx="startx $XINITRC -keeptty >$XDG_CACHE_HOME/.xorg.log 2>&1"

if ! tty -s || [ ! -n "$TERM" ] || [ "$TERM" = dumb ] || (( ! $+commands[grc] ))
then
  return
fi

# Supported commands
grc_cmds=(
  as
  ant
  blkid
  cc
  configure
  curl
  cvs
  df
  diff
  dig
  dnf
  docker
  docker-compose
  docker-machine
  du
  env
  fdisk
  findmnt
  free
  g++
  gas
  gcc
  getfacl
  getsebool
  gmake
  id
  ifconfig
  iostat
  ip
  iptables
  iwconfig
  journalctl
  kubectl
  last
  ldap
  lolcat
  ld
  # ls
  lsattr
  lsblk
  lsmod
  lsof
  lspci
  make
  mount
  mtr
  mvn
  netstat
  nmap
  ntpdate
  php
  ping
  ping6
  proftpd
  ps
  sar
  semanage
  sensors
  showmount
  sockstat
  ss
  stat
  sysctl
  systemctl
  tcpdump
  traceroute
  traceroute6
  tune2fs
  ulimit
  uptime
  vmstat
  wdiff
  whois
)

# Set alias for available commands.
for grc_cmd in $grc_cmds; do
  if [ -x "$(command -v $grc_cmd)" ]; then
    $grc_cmd() {
      grc --colour=auto ${commands[$0]} "$@"
    }
  fi
done

# Clean up variables
unset grc_cmds grc_cmd

if [ -x "$(command -v thefuck)" ]; then
  eval $(thefuck --alias fuck)
fi

# DOCKER
# alias dockerrm-dangle="docker rmi -f $(docker images -f "dangling=true" -q)"
alias drm-all="docker system prune -a"

# alias svim="sudo $EDITOR"
# alias vim=$EDITOR
#alias vi=$EDITOR
#alias v=$EDITOR

# alias _='sudo'

# Resource Usage
alias df='df -kh'
alias du='du -kh'
alias disk='df -h'
if cmd_exists ncdu; then
  alias usage="ncdu"
fi

if [ -x "$(command -v htop)" ]; then
  alias top=htop
else
  alias topc='top -o cpu'
  alias topm='top -o vsize'
fi

#### global aliases
alias -g NE='2>|/dev/null'
alias -g NO='&>|/dev/null'

if [ -x "$(command -v rg)" ]; then
  alias -g G='| rg'
  else
  alias -g G='| grep --color=auto'
fi
alias -g C='| wc -l'

if [ -x "$(command -v bat)" ]; then
  alias cat="bat"
  alias ccat="/bin/cat"
fi

# quality of life
alias -g ...='../..'
alias -g ....='../../..'
alias -g .....='../../../..'
alias -g ......='../../../../..'
alias -g .......='../../../../../..'
alias -g ........='../../../../../../..'


# ls
if [ -x "$(command -v lsd)" ]; then
  alias ls="lsd --group-dirs=first -1"
  alias ll='lsd --group-dirs=first -l'
  alias la='lsd --group-dirs=first -A'
  alias lla='lsd --group-dirs=first -lA'
  # tree
  alias lt='lsd --group-dirs=first --tree --depth=2 -A'
  alias lt1='lsd --group-dirs=first --tree --depth=1 -A'
  alias lt2='lsd --group-dirs=first --tree --depth=2 -A'
  alias lt3='lsd --group-dirs=first --tree --depth=3 -A'
  alias lt4='lsd --group-dirs=first --tree --depth=4 -A'
else
  alias ls="ls -G --color=auto --group-directories-first"
  alias ll='ls -l --color=auto --group-directories-first'
  alias la='ls -lA --color=auto --group-directories-first'
fi

# Copy with a progress bar
alias cpv="rsync -poghb --backup-dir=/tmp/rsync -e /dev/null --progress --"

alias xupdate="xrdb -merge $XDOTDIR/xresources"
alias zupdate="source $ZDOTDIR/.zshrc"

# Git
if [ -x "$(command -v git)" ]; then
  alias g="git"
  alias ga="git add"
  alias gaca="git add . && git commit -v"
  alias gb="git branch"
  alias gba="git branch -a"
  alias gc="git commit -v"
  alias gd="git diff | \$GIT_EDITOR -"
  alias gho="\$(git remote -v 2> /dev/null | grep github | sed -e \"s/.*git\:\/\/\([a-z]\.\)*/\1/\" -e \"s/\.git.*//g\" -e \"s/.*@\(.*\)\$/\1/g\" | tr \":\" \"/\" | tr -d \"\011\" | sed -e \"s/^/open http:\/\//g\" | uniq)"
  alias gl="git pull"
  alias gmv="git mv"
  alias gp="git push"
  alias gr="git stash && git svn rebase && git svn dcommit && git stash pop"
  alias gs="git stash"
  alias gsa="git stash apply"
  alias gsd="git svn dcommit"
  alias gsr="git svn rebase"
  alias gst="git status -sb"
  alias grmca="git rm -r --cached ."
fi
if cmd_exists lazygit; then
  alias lg="lazygit"
fi

# graphics
alias display_driver="lspci -k | grep -EA3 'VGA|3D|Display'"
alias graphic_driver="glxinfo | grep 'OpenGL renderer'"

# for fucks sake...
alias ffs="sudo !!"

# pretty print path
alias path='echo $PATH | tr -s ":" "\n"'
# alias path='echo -e ${PATH//:/\\n}'

alias speedtest="curl -s https://raw.githubusercontent.com/sivel/speedtest-cli/master/speedtest.py | python -"
# processes
alias psa="ps aux"

# vim aliases for quality of life
alias :q='exit'

alias ports="sudo lsof -PiTCP -sTCP:LISTEN"
