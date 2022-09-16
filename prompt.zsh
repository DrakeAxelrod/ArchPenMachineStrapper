if cmd_exists "starship"; then
  eval "$(starship init zsh)" # setup prompt
else
  curl -fsSL https://starship.rs/install.sh | sh
  eval "$(starship init zsh)" # setup prompt
fi
