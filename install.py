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
        execute(config["package_manager"] + " -Q " + package + " > /dev/null")
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
        print(f">> installing [{package}]")
        execute(config["package_manager"] + " -S " + package +
                " --noconfirm --needed --quiet")
    else:
        print(package + " is already installed")


def cp_config_dir(directory) -> None:
    """Copy directory from configs to .config

  Args:
      directory (string): directory to copy
  """
    # copy directory to ~/.config/directory except if git ignored
    shutil.copytree(f"configs/{directory}",
                    os.path.expanduser("~/.config/" + directory),
                    dirs_exist_ok=True)


def update():
    """Update system and install reflector if not installed and update mirrors"""
    global config

    execute(config["package_manager"] + " -Syu --noconfirm --quiet")
    execute(config["package_manager"] +
            " -S reflector --noconfirm --needed --quiet")
    execute(
        "sudo reflector --verbose --latest 5 --sort rate --save /etc/pacman.d/mirrorlist"
    )


# ======================== Configs ======================== #
def config_wrapper(func):
    """Configure wrapper"""
    print(f">> configuring [{func.__name__}]")
    func()


def systemd():
    """Configure systemd"""
    global config
    # enable systemd services
    for service in config["systemd_services"]:
        print(f">> configuring service [{service}]")
        execute("sudo systemctl enable " + service)
        execute("sudo systemctl start " + service)


def autostart_programs():
    # copy autostart directory to ~/.config/autostart except if git ignored
    cp_config_dir("autostart")


# configure ulauncher
def ulauncher():
  if check_package("ulauncher"):
    # copy config directories
    cp_config_dir("ulauncher")


# configure git
def git():
    """Configure git"""
    if check_package("git"):
      # copy git directory to ~/.config/git except if git ignored
      cp_config_dir("git")
    


# zsh
def zsh():
    """Configuring zsh"""
    if check_package("zsh"):
      os.environ["ZDOTDIR"] = os.path.expanduser("~/.config/zsh")
      # copy .zshenv to home directory and overwrite if exists
      # change default shell redirect password to stdin if zsh is not default shell
      if os.environ["SHELL"] != "/bin/zsh":
          execute("chsh -s /bin/zsh")
      shutil.copyfile("configs/zshenv", os.path.expanduser("~/.zshenv"))
      cp_config_dir("zsh")


def kitty():
    """Configure kitty"""
    if check_package("kitty"):
    # copy kitty directory to ~/.config/kitty except if git ignored
      cp_config_dir("kitty")


# lunarvim
def lunarvim():
    """Configure lunarvim"""
    if check_package("neovim"):
      # set environment variable
      os.environ["LV_BRANCH"] = "rolling"
      # install lunarvim
      execute("./scripts/lunarvim.sh -y --install-dependencies")
      # copy lunarvim directory to ~/.config/lunarvim except if git ignored
      cp_config_dir("lvim")


# install and configure cargo
def rust():
    """Configure rustup"""
    os.environ["CARGO_HOME"] = os.path.expanduser("~/.local/share/cargo")
    os.environ["RUSTUP_HOME"] = os.path.expanduser("~/.local/share/rustup")
    # set rustup to stable
    os.system("rustup default stable")
    if os.path.exists(os.path.expanduser("~/.rustup")):
        shutil.rmtree(os.path.expanduser("~/.rustup"))
    if os.path.exists(os.path.expanduser("~/.cargo")):
        shutil.rmtree(os.path.expanduser("~/.cargo"))


# ======================== Main ======================== #


def pretty_print(msg, color="\033[92m"):
    """Print message in pretty format

  Args:
      msg (string): message to print
  """
    # print message in pretty format colored green and bold with centered text and wrapped in = signs
    print(f"""
{color}{'=' * 74}
{msg.center(74)}
{'=' * 74}\033[0m
""")


if __name__ == "__main__":
    global config
    # start
    print("\033[96m" + banner + "\033[0m")
    config = read_config()
    # update system and mirrorlist
    # pretty_print(
    #     "Performing system update and mirrorlist update please do not exit",
    #     "\033[91m")
    # ask if user wants to update system and mirrors
    print("\033[91m" + "do you want to update system and mirrors? [y/n]" + "\033[0m", end=" ")
    ans = input().lower()
    if ans == "y" or ans == "yes":
      update()
    else:
      print(">> skipping update")

    # install packages green
    pretty_print("Installing general packages")
    for package in config["packages"]["general"]:
        install_package(package)

    # configuring system

    pretty_print("Configuring system")
    systemd()

    for func in [git, zsh, rust, autostart_programs, ulauncher, lunarvim, kitty]:
        config_wrapper(func)

    # install pentest tools
    pretty_print("Installing pentest tools")
    for package in config["packages"]["pentest_tools"]:
        install_package(package)
