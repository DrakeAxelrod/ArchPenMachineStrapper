#!/usr/bin/env zsh

# =============================================================================================== #

# colors
autoload -U colors && colors	# Load colors

# completion settings
autoload -Uz compinit
zmodload zsh/complist

compinit -d $ZSH_COMPDUMP

# =============================================================================================== #

# setopt correct						# ask [nyae]? when you type something wrong
# setopt correct_all					# same as above
#setopt autocd           	       	# Change to a directory just by typing its name
setopt auto_pushd               	# Make cd push each old directory onto the stack
setopt cdable_vars              	# Like AUTO_CD, but for named directories
setopt pushd_ignore_dups 	      	# Don't push duplicates onto the stack
setopt extended_glob            	# Treat the '#', '~' and '^' characters as part of patterns for filename generation, etc.
setopt no_case_glob     	       	# Case Insensitive Globbing
setopt NUMERIC_GLOB_SORT                    # Sort globs that expand to numbers numerically, not by letter (i.e. 01 2 03)
setopt nomatch                  	# If a pattern for filename generation has no matches, print an error, instead of leaving it unchanged in the argument list. This also applies to file expansion of an initial '~' or '='.
setopt menu_complete            	# n an ambiguous completion, instead of listing possibilities or beeping, insert the first match immediately. Then when completion is requested again, remove the first match and insert the second match, etc.
setopt no_list_ambiguous        	# It will correct things like "c" to "C" and show the completion menu.
setopt interactive_comments     	# Allow comments in interactive mode
setopt no_beep                  	# beep is super annoying
setopt no_flow_control          	# Disables the use of ⌃S to stop terminal output and the use of ⌃Q to resume it.
setopt always_to_end                # When completing from the middle of a word, move cursor to end of word
setopt complete_aliases         	# autocompletion of command line switches for aliases

# History
HISTSIZE=50000
SAVEHIST=50000
setopt extended_history         # Write timestamps to history
setopt append_history           # just append history
setopt hist_expire_dups_first   # If history needs to be trimmed, evict dups first
setopt hist_find_no_dups        # Don't show dups when searching history
setopt hist_ignore_dups         # Don't add consecutive dups to history
setopt hist_ignore_space        # Don't add commands starting with space to history
setopt hist_reduce_blanks       # removes blank lines from history
setopt hist_verify              # If a command triggers history expansion, show it instead of running
setopt share_history            # Write and import history on every command

# colors
autoload -U colors && colors	# Load colors

# completion settings
# autoload -Uz compinit
# zmodload zsh/complist

# compinit -d $ZCACHE/.zcompdump
_comp_options+=(globdots)		     # Include hidden files.

zstyle ':completion:*' accept-exact '*(N)'
zstyle ':completion:*' use-cache on
zstyle ':completion:*' cache-path $ZSH_CONF_DIR/cache
zstyle ':completion:*' squeeze-slashes yes

# 2007-10-03: complete word from history.
# Note this may be the single coolest snippet in this config.
zle -C hist-complete complete-word _generic
bindkey '^N'  hist-complete
zstyle ':completion:hist-complete:*' completer _history
zstyle ':completion:hist-complete:*' sort false # newest match first
zstyle ':completion:hist-complete:*' range 12000:8000
zstyle ':completion:hist-complete:*' matcher-list 'b:=*'
zstyle ':completion:hist-complete:*' remove-all-dups yes

# do menu-driven completion.
zstyle ':completion:*' menu select

zstyle ':completion:*' matcher-list 'm:{a-z}={A-Z}'     # Case-insensitive (uppercase from lowercase) completion
# colors

# formatting and messages
zstyle ':completion:*' verbose yes
zstyle ':completion:*' auto-description 'specify: %d'
zstyle ':completion:*:corrections' format $'%{\e[0;31m%}%d (errors: %e, orig `%o\')%{\e[0m%}'
zstyle ':completion:*:descriptions' format $'%{\e[0;31m%}completing %B%d%b%{\e[0m%}'
zstyle ':completion:*:messages' format $'%{\e[0;31m%}%d%{\e[0m%}'
zstyle ':completion:*:warnings' format $'%{\e[0;31m%}No matches for: %d%{\e[0m%}'
zstyle ':completion:*' group-name ''

# expand alias on tab
zstyle ':completion:*' completer _expand_alias _complete _ignored

# Typically, compinit will not automatically find new executables in the $PATH. 
# For example, after you install a new package, the files in /usr/bin/ would not be immediately or automatically included in the completion. 
# Thus, to have these new executables included, one would run:
zstyle ':completion:*' rehash true  # automatic rehashing
