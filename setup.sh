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
  chsh -s $(which zsh)
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

echo "Setting up oh-my-zsh..."
if [ ! -d "~/.oh-my-zsh" ]; then
    ZSH=${ZSH:-~/.oh-my-zsh}
    REPO=${REPO:-ohmyzsh/ohmyzsh}
    REMOTE=${REMOTE:-https://github.com/${REPO}.git}
    BRANCH=${BRANCH:-master}

    git clone -c core.eol=lf -c core.autocrlf=false \
    -c fsck.zeroPaddedFilemode=ignore \
    -c fetch.fsck.zeroPaddedFilemode=ignore \
    -c receive.fsck.zeroPaddedFilemode=ignore \
    --depth=1 --branch "$BRANCH" "$REMOTE" "$ZSH" || {
        fmt_error "git clone of oh-my-zsh repo failed"
        exit 1
    }

    # fzf-tab
    git clone https://github.com/Aloxaf/fzf-tab ${ZSH_CUSTOM:-~/.oh-my-zsh/custom}/plugins/fzf-tab

    # zsh config
    cp ~/dotfiles/.zshrc ~/.zshrc
fi

echo "Copying rest of configuration..."
cp ~/dotfiles/.gitconfig ~/.gitconfig
cp ~/dotfiles/.tmux.conf ~/.tmux.conf


echo "DONE!"