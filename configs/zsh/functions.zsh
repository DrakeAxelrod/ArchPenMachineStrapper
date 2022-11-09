#! /usr/bin/env zsh

function cmd_exists() {
  if [ -x "$(command -v $1)" ]; then
    return true
  else
    return false
  fi
}

# Docker related shit

function drmdangle() {
  docker rmi -f $(docker images -f "dangling=true" -q)
}

function dprune() {
  docker system prune "$@"
}

function dbuild() {
  docker build -t $1 -f Dockerfile .
}

function drun() {
  docker run --rm "$@"
}


# Create a new directory and enter it
function mk() {
	mkdir -p "$@" && cd "$@"
}

# cd into dir and list contents
function lc() {
    cd "$1" && la "$2"
}

# Extract archives - use: extract <file>
# Based on http://dotfiles.org/~pseup/.bashrc
function extract() {
	if [ -f "$1" ] ; then
		local filename=$(basename "$1")
		local foldername="${filename%%.*}"
		local fullpath=`perl -e 'use Cwd "abs_path";print abs_path(shift)' "$1"`
		local didfolderexist=false
		if [ -d "$foldername" ]; then
			didfolderexist=true
			read -p "$foldername already exists, do you want to overwrite it? (y/n) " -n 1
			echo
			if [[ $REPLY =~ ^[Nn]$ ]]; then
				return
			fi
		fi
		mkdir -p "$foldername" && cd "$foldername"
		case $1 in
			*.tar.bz2) tar xjf "$fullpath" ;;
			*.tar.gz) tar xzf "$fullpath" ;;
			*.tar.xz) tar Jxvf "$fullpath" ;;
			*.tar.Z) tar xzf "$fullpath" ;;
			*.tar) tar xf "$fullpath" ;;
			*.taz) tar xzf "$fullpath" ;;
			*.tb2) tar xjf "$fullpath" ;;
			*.tbz) tar xjf "$fullpath" ;;
			*.tbz2) tar xjf "$fullpath" ;;
			*.tgz) tar xzf "$fullpath" ;;
			*.txz) tar Jxvf "$fullpath" ;;
			*.zip) unzip "$fullpath" ;;
			*) echo "'$1' cannot be extracted via extract()" && cd .. && ! $didfolderexist && rm -r "$foldername" ;;
		esac
	else
		echo "'$1' is not a valid file"
	fi
}

# direct it all to /dev/null
function nullify() {
  "$@" >/dev/null 2>&1
}

#use generalized open command
function open_command() {
  emulate -L zsh
  setopt shwordsplit
 
  local open_cmd
 
  # define the open command
  case "$OSTYPE" in
    darwin*)  open_cmd='open' ;;
    cygwin*)  open_cmd='cygstart' ;;
    linux*)   open_cmd='xdg-open' ;;
    msys*)    open_cmd='start ""' ;;
    *)        echo "Platform $OSTYPE not supported"
              return 1
              ;;
  esac
 
  # don't use nohup on OSX
  if [[ "$OSTYPE" == darwin* ]]; then
    $open_cmd "$@" &>/dev/null
  else
    nohup $open_cmd "$@" &>/dev/null
  fi
}

# function to append to path
function pathmunge() {
    A=0  # append flag
    E=0  # use `eval` flag
    H=0  # show help flag
    S=":" # separator

    while getopts "aes:" option; do
        case $option in
            a) A=1         ;;
            e) E=1         ;;
            s) S="$OPTARG" ;;
        esac
    done

    shift $((OPTIND - 1))
    unset option OPTARG

    if [ -z "$2" ]; then
        var='PATH'
        new="$1"
    else
        var="$1"
        new="$2"
    fi

    eval val="\$$var"

    case "$S$val$S" in
        *"$S$new$S"*) ;;
        "$S$S") updated="$new" ;;
        *) [ "$A" = "0" ] && updated="$new$S$val" || updated="$val$S$new" ;;
    esac

    if [ -n "$updated" ]; then
        if [ "$E" = "0" ]; then
            export "$var"="$updated"
        else
            eval "$var='$updated'"
        fi
    fi

    unset A S E var new val updated
}

# pacman
function pacman_packages() {
  local packages="$(LC_ALL=C yay -Qi | awk '/^Name/{name=$3} /^Installed Size/{print $4$5, name}' | sort -h)"
  echo $packages > $XDG_CONFIG_HOME/arch-installed-packages.txt
  echo >> $XDG_CONFIG_HOME/arch-installed-packages.txt
  df -h >> $XDG_CONFIG_HOME/arch-installed-packages.txt
}

# Change file extensions recursively in current directory
function change_extension() {
  foreach f (**/*.$1)
    mv $f $f:r.$2
  end
}

# Determine size of a file or total size of a directory
function fs() {
	if du -b /dev/null > /dev/null 2>&1; then
		local arg=-sbh;
	else
		local arg=-sh;
	fi
	if [[ -n "$@" ]]; then
		du $arg -- "$@";
	else
		du $arg .[^.]* ./*;
	fi;
}

# Create a data URL from a file
function dataurl() {
	local mimeType=$(file -b --mime-type "$1");
	if [[ $mimeType == text/* ]]; then
		mimeType="${mimeType};charset=utf-8";
	fi
	echo "data:${mimeType};base64,$(openssl base64 -in "$1" | tr -d '\n')";
}

# Start a PHP server from a directory, optionally specifying the port
# (Requires PHP 5.4.0+.)
function phpserver() {
	local port="${1:-4000}";
	local ip=$(ipconfig getifaddr en1);
	sleep 1 && open "http://${ip}:${port}/" &
	php -S "${ip}:${port}";
}

if [ ! $(uname -s) = 'Darwin' ]; then
	if grep -q Microsoft /proc/version; then
		# Ubuntu on Windows using the Linux subsystem
		alias open='explorer.exe';
	else
		alias open='xdg-open';
	fi
fi

# `o` with no arguments opens the current directory, otherwise opens the given
# location
function o() {
	if [ $# -eq 0 ]; then
		open .;
	else
		open "$@";
	fi;
}

function example() {
  echo "EXAMPLE:";
  echo;
  echo " $@";
  echo;
  echo "OUTPUT:";
  echo ;
  eval "$@" | sed 's/^/ /';
}

function mans(){
    man -k . \
    | fzf -n1,2 --preview "echo {} \
    | cut -d' ' -f1 \
    | sed 's# (#.#' \
    | sed 's#)##' \
    | xargs -I% man %" --bind "enter:execute: \
      (echo {} \
      | cut -d' ' -f1 \
      | sed 's# (#.#' \
      | sed 's#)##' \
      | xargs -I% man % \
      | less -R)"
}

function git_log() {
  git log --graph --color=always \
      --format="%C(auto)%h%d %s %C(black)%C(bold)%cr" "$@" \
  | fzf --ansi --preview "echo {} \
    | grep -o '[a-f0-9]\{7\}' \
    | head -1 \
    | xargs -I % sh -c 'git show --color=always %'" \
        --bind "enter:execute:
            (grep -o '[a-f0-9]\{7\}' \
                | head -1 \
                | xargs -I % sh -c 'git show --color=always % \
                | less -R') << 'FZF-EOF'
            {}
FZF-EOF"
}

function lazycommit() {
  git add -A
  git commit -m "$1"
  git push
}

# just fun
# function flip() { echo -n "（╯°□°）╯ ┻━┻\n" |tee /dev/tty| xclip -selection clipboard; }
# function disappointed() { echo -n " ಠ_ಠ \n" |tee /dev/tty| xclip -selection clipboard; }
# function shrug() { echo -n "¯\_(ツ)_/¯\n" |tee /dev/tty| xclip -selection clipboard; }
# function matrix() { echo -e "\e[1;40m" ; clear ; while :; do echo $LINES $COLUMNS $(( $RANDOM % $COLUMNS)) $(( $RANDOM % 72 )) ;sleep 0.05; done|awk '{ letters="abcdefghijklmnopqrstuvwxyzABCDEFGHIJKLMNOPQRSTUVWXYZ0123456789@#$%^&*()"; c=$4;        letter=substr(letters,c,1);a[$3]=0;for (x in a) {o=a[x];a[x]=a[x]+1; printf "\033[%s;%sH\033[2;32m%s",o,x,letter; printf "\033[%s;%sH\033[1;37m%s\033[0;0H",a[x],x,letter;if (a[x] >= $1) { a[x]=0; } }}' }

function up() { 
  local DEEP=$1;
  [ -z "${DEEP}" ] && { DEEP=1; };
  for i in $(seq 1 ${DEEP});
  do cd ../;
  done;
}

function dir_content_to_lower() {
  for i in *; do
    mv "$i" "${i,,}";
  done;
}

# Automatically list directory contents on `cd`.
# auto-ls () {
# 	emulate -L zsh;
# 	# explicit sexy ls'ing as aliases arent honored in here.
# 	hash gls >/dev/null 2>&1 && CLICOLOR_FORCE=1 gls -aFh --color --group-directories-first || ls
# }
# chpwd_functions=( auto-ls )

# Checks a boolean variable for "true".
# Case insensitive: "1", "y", "yes", "t", "true", "o", and "on".
function is-true {
  [[ -n "$1" && "$1" == (1|[Yy]([Ee][Ss]|)|[Tt]([Rr][Uu][Ee]|)|[Oo]([Nn]|)) ]]
}

# Checks a name if it is a command, function, or alias.
function is-callable {
  (( $+commands[$1] )) || (( $+functions[$1] )) || (( $+aliases[$1] ))
}



# alias sudoedit if it doesnt exist
if (( ! $+commands[sudoedit] )); then
  alias sudoedit='sudo -e '
fi


function encode64 {
  echo -n $1 | base64
}

function decode64 {
  echo -n $1 | base64 -d
}

pathAppend() {
  # Only adds to the path if it's not already there
  if ! echo $PATH | egrep -q "(^|:)$1($|:)" ; then
    PATH=$PATH:$1
  fi
}

function color() {
    local fgc bgc vals seq0

    printf "Color escapes are %s\n" '\e[${value};...;${value}m'
    printf "Values 30..37 are \e[33mforeground colors\e[m\n"
    printf "Values 40..47 are \e[43mbackground colors\e[m\n"
    printf "Value  1 gives a  \e[1mbold-faced look\e[m\n\n"

    # foreground colors
    for fgc in {30..37}; do
        # background colors
        for bgc in {40..47}; do
            fgc=${fgc#37} # white
            bgc=${bgc#40} # black

            vals="${fgc:+$fgc;}${bgc}"
            vals=${vals%%;}

            seq0="${vals:+\e[${vals}m}"
            printf "  %-9s" "${seq0:-(default)}"
            printf " ${seq0}TEXT\e[m"
            printf " \e[${vals:+${vals+$vals;}}1mBOLD\e[m"
        done
        echo
        echo
    done
}

function spwd {
  paths=(${(s:/:)PWD})

  cur_path='/'
  cur_short_path='/'
  for directory in ${paths[@]}
  do
    cur_dir=''
    for (( i=0; i<${#directory}; i++ )); do
      cur_dir+="${directory:$i:1}"
      matching=("$cur_path"/"$cur_dir"*/)
      if [[ ${#matching[@]} -eq 1 ]]; then
        break
      fi
    done
    cur_short_path+="$cur_dir/"
    cur_path+="$directory/"
  done

  printf %q "${cur_short_path: : -1}"
  echo
}

function short_pwd() {
    cwd=$(pwd | perl -F/ -ane 'print join( "/", map { $i++ < @F - 1 ?  substr $_,0,1 : $_ } @F)')
    echo -n $cwd
}
export SPWD="$(short_pwd)"
