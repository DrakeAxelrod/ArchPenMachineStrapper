#! /usr/bin/env python

import os
import sys
import shutil
import subprocess
from getpass import getpass

# ==================== SETTINGS ==================== #
# you can change these
# ================================================== #

# globals
package_manager = "yay"

# general packages
packages = [
  "imwheel",
  "keybase-bin",
  "open-vm-tools",
  "nerd-fonts-jetbrains-mono",
  "git",
  "zsh",
  "kitty",
  "neovim",
  "bat",
  "ripgrep",
  "fd",
  "lsd",
  "grc",
  "ncdu",
  "papirus-icon-theme",
  "thefuck",
  "rustup",
]
pentesting_tools = [
  # General
  "nmap",
  "vulscan",
  "metasploit",
  "wordlists",
  "burpsuite",
  "burpsuite-pro",
  # sql injection tools
  "sqlmap",
  # directory traversal
  "gobuster",
  "dirb",
  "dirbuster",
  # 
  "nikto",
]

# ================================================== #
# don't change from here and below
# ================================================== #

banner = """
==========================================================================
  ___           _    ______         ___  ___           _     _            
 / _ \         | |   | ___ \        |  \/  |          | |   (_)           
/ /_\ \_ __ ___| |__ | |_/ /__ _ __ | .  . | __ _  ___| |__  _ _ __   ___ 
|  _  | '__/ __| '_ \|  __/ _ \ '_ \| |\/| |/ _` |/ __| '_ \| | '_ \ / _ \\
| | | | | | (__| | | | | |  __/ | | | |  | | (_| | (__| | | | | | | |  __/
\_| |_/_|  \___|_| |_\_|  \___|_| |_\_|  |_/\__,_|\___|_| |_|_|_| |_|\___|
================================== Developed by: Drake Axelrod (draxel.io)
"""

# utility functions
sudo_password = "" # don't change this
# get password for sudo
def get_sudo_password():
  global sudo_password
  # print in yellow
  print("\033[93m" + "in order to install packages and configure the system, we need your sudo password"  + "\033[0m")
  sudo_password = getpass("sudo password: " )

# function to pipe password to stdin of command
def pipe_password(command):
  return subprocess.Popen(command, stdin=subprocess.PIPE, shell=True).communicate(sudo_password.encode())

# copy directory to .config
def copy_config_directory(directory):
  # copy directory to ~/.config/directory except if git ignored
  shutil.copytree(directory, os.path.expanduser("~/.config/" + directory), dirs_exist_ok=True)

# check if package is installed
def is_package_installed(package):
  return os.system(package_manager + " -Q " + package + " > /dev/null") == 0

# install package if not installed
def install_package(package):
  if not is_package_installed(package):
    print("Installing package: " + package)
    pipe_password(package_manager + " -S " + package + " --noconfirm")


# Setup functions

# open-vm-tools
def configure_open_vm_tools():
  print("Configuring open-vm-tools")
  # enable services if not enabled
  # check if service symlink exists
  if not os.path.exists("/etc/systemd/system/multi-user.target.wants/open-vm-tools.service"):
    pipe_password("systemctl enable vmtoolsd")
  if not os.path.exists("/etc/systemd/system/multi-user.target.wants/vmware-vmblock-fuse.service"):
    pipe_password("systemctl enable vmware-vmblock-fuse")
  # start services if not started
  if not os.system("systemctl is-active --quiet vmtoolsd"):
    pipe_password("systemctl start vmtoolsd")
  if not os.system("systemctl is-active --quiet vmware-vmblock-fuse"):
    pipe_password("systemctl start vmware-vmblock-fuse")

# configure autostart programs
def configure_autostart():
  print("Configuring autostart programs")
  # copy autostart directory to ~/.config/autostart except if git ignored
  copy_config_directory("autostart")

# configure ulauncher
def configure_ulauncher():
  print("Configuring ulauncher")
  # copy config directories
  copy_config_directory("ulauncher")

# configure git
def configure_git():
  print("Configuring git")
  # copy git directory to ~/.config/git except if git ignored
  copy_config_directory("git")

# zsh
def configure_zsh():
  print("Configuring zsh")
  # copy .zshenv to home directory and overwrite if exists
  # change default shell redirect password to stdin if zsh is not default shell
  if os.environ["SHELL"] != "/bin/zsh":
    pipe_password("chsh -s /bin/zsh")
  shutil.copyfile("zshenv", os.path.expanduser("~/.zshenv"))
  copy_config_directory("zsh")

# kitty
def configure_kitty():
  print("Configuring kitty")
  # copy kitty directory to ~/.config/kitty except if git ignored
  copy_config_directory("kitty")

# lunarvim
def configure_lunarvim():
  print("Installing lunarvim")
  # set environment variable
  os.environ["LV_BRANCH"] = "rolling"
  link = "https://raw.githubusercontent.com/ChristianChiarulli/lunarvim/rolling/utils/installer/install.sh"

  os.system(f"bash <(curl -s {link}) --install-dependencies -y")
  # copy lunarvim directory to ~/.config/lunarvim except if git ignored
  copy_config_directory("lvim")

# install and configure cargo
def configure_rustup():
  print("Installing rustup")
  os.system("rustup default stable")

def main():
  # update system
  # print banner in blue if terminal supports it
  if os.system("tput colors > /dev/null") == 0:
    print("\033[94m" + banner + "\033[0m")
  else:
    print(banner)
  # get sudo password
  get_sudo_password()
  # update system
  print("Updating system")
  pipe_password(package_manager + " -Syu --noconfirm")
  # install packages
  for package in packages:
    install_package(package)

  # configure_open_vm_tools()
  configure_rustup()
  configure_git()
  configure_zsh()
  configure_kitty()
  configure_lunarvim()
  configure_autostart()
  configure_ulauncher()

  # install pentest tools
  print("Installing pentest tools")
  for tool in pentest_tools:
    install_package(tool)




if __name__ == "__main__":
  main()
