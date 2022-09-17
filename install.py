import subprocess
import yaml
import shutil
import os

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

# ======================== Utils ======================== #

def read_config() -> dict:
  """Load the config.yml

  Returns:
      dict: configurations
  """
  # open config.yml
  return yaml.load(open("config.yml"), Loader=yaml.FullLoader)


def execute(cmd) -> str:
  """Execute system commands and return output

  Args:
      cmd (string): command to execute

  Returns:
      str: output of command
  """
  return subprocess.check_output(cmd, shell=True).decode("utf-8")

def check_package(package) -> bool:
  """Check if package is installed

  Args:
      package (string): package to check

  Returns:
      bool: if package is installed
  """
  global config
  # check if error code then package is not installed
  try:
    execute(config["package_manager"] + " -Q " + package)
    return True
  except:
    return False

def install_package(package) -> None:
  """Install package if not installed

  Args:
      package (string): package to install
  """
  global config
  if not check_package(package):
    execute(config["package_manager"] + " -S " + package + " --noconfirm --needed --quiet")

def cp_config_dir(directory) -> None:
  """Copy directory from configs to .config

  Args:
      directory (string): directory to copy
  """
  # copy directory to ~/.config/directory except if git ignored
  shutil.copytree(f"configs/{directory}", os.path.expanduser("~/.config/" + directory), dirs_exist_ok=True)

# ======================== Configs ======================== #
def configure_systemd():
  """Configure systemd
  """
  global config
  # enable systemd services
  for service in config["systemd_services"]:
    execute("sudo systemctl enable " + service)
    execute("sudo systemctl start " + service)

def configure_autostart():
  print("Configuring autostart programs")
  # copy autostart directory to ~/.config/autostart except if git ignored
  cp_config_dir("autostart")

# configure ulauncher
def configure_ulauncher():
  print("Configuring ulauncher")
  # copy config directories
  cp_config_dir("ulauncher")

# configure git
def configure_git():
  print("Configuring git")
  # copy git directory to ~/.config/git except if git ignored
  cp_config_dir("git")

# zsh
def configure_zsh():
  """Configure zsh"""
  print("Configuring zsh")
  # copy .zshenv to home directory and overwrite if exists
  # change default shell redirect password to stdin if zsh is not default shell
  if os.environ["SHELL"] != "/bin/zsh":
    execute("chsh -s /bin/zsh")
  shutil.copyfile("configs/zshenv", os.path.expanduser("~/.zshenv"))
  
  cp_config_dir("zsh")

def configure_kitty():
  """Configure kitty"""
  print("Configuring kitty")
  # copy kitty directory to ~/.config/kitty except if git ignored
  cp_config_dir("kitty")

# lunarvim
def configure_lunarvim():
  """Configure lunarvim"""
  print("Configure lunarvim")
  # set environment variable
  os.environ["LV_BRANCH"] = "rolling"
  # install lunarvim
  execute("./scripts/lunarvim.sh -y --install-dependencies")
  # copy lunarvim directory to ~/.config/lunarvim except if git ignored
  cp_config_dir("lvim")

# install and configure cargo
def configure_rustup():
  """Configure rustup"""
  print("Configure rustup")
  os.system("rustup default stable")

# ======================== Main ======================== #
if __name__ == "__main__":
  global config
  # start
  print("\033[96m" + banner + "\033[0m")
  config = read_config()
  # install packages
  print("Installing general packages")
  for package in config["packages"]["general"]:
    install_package(package)

  # configuring system
  configure_git()
  configure_systemd()
  configure_zsh()
  configure_rustup()
  configure_autostart()
  configure_ulauncher()
  configure_lunarvim()
  configure_kitty()
  
  # install pentest tools
  print("Installing pentest tools")
  for package in config["packages"]["pentest_tools"]:
    install_package(package)
