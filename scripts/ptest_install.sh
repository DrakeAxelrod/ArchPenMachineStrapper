#! /usr/bin/env bash

PACKAGE_MANAGER="yay"
PACKAGE_MANAGER_FLAGS="-S --noconfirm"

packages=(
  "nerd-fonts-jetbrains-mono"
  "git"
  "neovim"
  "bat"
  "ripgrep"
  "fd"
  "lsd"
  "grc"
  "ncdu"
  "papirus-icon-theme"
  "thefuck"
  "kitty"
)

pentest_tools=(
  # General
  "nmap"
  "vulscan"
  "metasploit"
  "wordlists"
  "burpsuite"
  "burpsuite-pro"
  # sql injection tools
  "sqlmap"
  # directory traversal
  "gobuster"
  "dirb"
  "dirbuster"
  # 
  "nikto"
)

# install rustup and configure
function install_rustup() {
  $PACKAGE_MANAGER $PACKAGE_MANAGER_FLAGS rustup
  rustup default stable
}

function install_packages() {
  # pass in an array of packages to install
  packages=("$@")
  for package in "${packages[@]}"; do
    echo "Installing $package"
    $PACKAGE_MANAGER $PACKAGE_MANAGER_FLAGS $package
  done
}

# setup general tools
function setup_general_tools() {
  echo "Installing General Packages"
  # install rustup
  install_rustup
  # install packages
  install_packages "${packages[@]}"
}

# setup pentest tools
function setup_pentest_tools() {
  echo "Installing Pentest Packages"
  install_packages "${pentest_tools[@]}"
}

setup_general_tools
setup_pentest_tools

unset packages package pentest_tools
