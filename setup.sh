#!/usr/bin/env bash
set -e

command_exists() {
	command -v "$@" >/dev/null 2>&1
}

fmt_error() {
  printf '%sError: %s%s\n' "$BOLD$RED" "$*" "$RESET" >&2
}

setup_color() {
	# Only use colors if connected to a terminal
	if [ -t 1 ]; then
		RED=$(printf '\033[31m')
		GREEN=$(printf '\033[32m')
		YELLOW=$(printf '\033[33m')
		BLUE=$(printf '\033[34m')
		BOLD=$(printf '\033[1m')
		RESET=$(printf '\033[m')
	else
		RED=""
		GREEN=""
		YELLOW=""
		BLUE=""
		BOLD=""
		RESET=""
	fi
}

setup_color

echo "${GREEN} ~Mollys Environment Setup~${RESET}"

if ! [ $SPIN ]; then
    fmt_error '!THIS SETUP IS INTENDED FOR A SPIN ENVIRONMENT ONLY!'
    exit 1
fi

echo 'dependency install and setup...'

if ! command_exists zsh; then
  sudo apt-get install -y zsh
  # chsh -s $(which zsh)
fi

if ! command_exists ag; then
  sudo apt-get install -y silversearcher-ag
fi

if ! command_exists fzf; then
  sudo apt-get install -y fzf
fi

if ! command_exists ranger; then
  sudo apt-get install -y ranger
fi

if ! command_exists batcat; then
  sudo apt-get install -y bat
fi

if ! command_exists wget; then
  sudo apt-get install -y wget
fi

if ! command_exists delta: then
  local tmp_deb="$(mktemp)"
  local src_url="https://github.com/barnumbirr/delta-debian/releases/download/0.6.0-1/delta-diff_0.6.0-1_amd64_debian_testing.deb"

  wget -O $tmp_deb $src_url &&
  sudo dpkg -i $tmp_deb &&
  { rm -f $tmp_deb; true; } ||
  { rm -f $tmp_deb; false; }
fi

echo "Setting up oh-my-zsh..."
if [ ! -d "~/.oh-my-zsh" ]; then
  sh -c "$(curl -fsSL https://raw.githubusercontent.com/ohmyzsh/ohmyzsh/master/tools/install.sh)" "" --unattended

  # fzf-tab
  git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

fi

echo "Copying rest of configuration..."
cp ~/dotfiles/.zshrc ~/.zshrc
cp ~/dotfiles/.gitconfig ~/.gitconfig
cp ~/dotfiles/.tmux.conf ~/.tmux.conf

echo "Reportify setup..."
# Only run nested steps in Spin + shopify/shopify workspaces.
if [[ "$SPIN_REPO_SOURCE_PATH" = "/src/github.com/shopify/shopify" ]]
then
  cd "$SPIN_REPO_SOURCE_PATH"
  # This will always be the author of the cartridge, so for the shopify-reportify-config it will be shameelabd (do not modify this)
  # Do **NOT** replace this username with your username.
  cartridge insert shameelabd/shopify-reportify-config
  . /cartridges/shopify-reportify-config/setup.sh
  restart
  fi

echo "DONE!"
