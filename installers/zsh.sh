#! /usr/bin/env zsh

export ZPLUG_HOME="$HOME/.config/zsh/zplug"

# zplug
curl -sL --proto-redir -all,https https://raw.githubusercontent.com/zplug/installer/master/installer.zsh | zsh

# starship
sh <(curl -fsSL https://starship.rs/install.sh) -y
