#!/usr/bin/env zsh

source "$ZPLUG_HOME/init.zsh"

# if [ -x "$(command -v zplug)" ]; then
#   curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh
#   source "$ZPLUG_HOME/init.zsh"
# fi

# # Syntax highlighting bundle.
zplug zsh-users/zsh-syntax-highlighting
zplug zdharma-continuum/fast-syntax-highlighting
# # completion bundle.
zplug zsh-users/zsh-completions
zplug zsh-users/zsh-history-substring-search
zplug zsh-users/zsh-autosuggestions
# # you-should-use
zplug MichaelAquilina/zsh-you-should-use
# # vi mode
zplug jeffreytse/zsh-vi-mode
zvm_config() {}

# z.lua
zplug skywind3000/z.lua, as:command
eval "$(lua $_ZLPATH --init zsh enhanced once fzf)"

# Install plugins if there are plugins that have not been installed
if ! zplug check --verbose; then
    printf "Install? [y/N]: "
    if read -q; then
        echo; zplug install
    fi
fi

# load the plugins
zplug load
