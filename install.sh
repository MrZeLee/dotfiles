#!/bin/bash

# Determine the operating system
OS_TYPE=$(uname)
echo "Operating System: $OS_TYPE"

# Check if Nix is already installed
if ! command -v nix &> /dev/null; then
  echo "Nix is not installed. Installing Nix..."
  # Install Nix
  curl -L https://nixos.org/nix/install | sh
else
  echo "Nix is already installed."
fi

# If the operating system is macOS
if [ "$OS_TYPE" = "Darwin" ]; then
  # Check if Homebrew is installed
  if ! command -v brew &> /dev/null; then
    echo "Homebrew is not installed. Installing Homebrew..."
    /bin/bash -c "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/HEAD/install.sh)"
  else
    echo "Homebrew is already installed."
  fi
fi

# Check if Git is installed; if not, install it using Nix
if ! command -v git &> /dev/null; then
  echo "Git is not installed. Installing Git with Nix..."
  nix-env -iA nixpkgs.git
else
  echo "Git is already installed."
fi

# Check if $HOME/.dotfiles exists; if not, clone the repository
if [ ! -d "$HOME/.dotfiles" ]; then
  echo "Directory $HOME/.dotfiles does not exist. Cloning repository..."
  git clone https://github.com/MrZeLee/dotfiles "$HOME/.dotfiles"
else
  echo "Directory $HOME/.dotfiles already exists."
  cd "$HOME/.dotfiles" && git pull
fi

# Run nix-darwin switch with flake if macOS
if [ "$OS_TYPE" = "Darwin" ]; then
  nix run nix-darwin -- switch --flake ~/.config/nix-darwin
  darwin-rebuild switch --flake ~/.config/nix-darwin
fi
