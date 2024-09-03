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

# Check if stow is installed; if not, install it using Nix
if ! command -v stow &> /dev/null; then
  echo "Stow is not installed. Installing Stow with Nix..."
  nix-env -iA nixpkgs.stow
else
  echo "Stow is already installed."
fi

# Run stow in the $HOME/.dotfiles directory
echo "Running stow in $HOME/.dotfiles to symlink the dotfiles..."
cd $HOME/.dotfiles && stow .

# Check if com.apple.HIToolbox.plist differs between $HOME/.dotfiles and $HOME/Library/Preferences
if [ "$OS_TYPE" = "Darwin" ]; then
  DOTFILES_PLIST="$HOME/.dotfiles/com.apple.HIToolbox.plist"
  PREFERENCES_PLIST="$HOME/Library/Preferences/com.apple.HIToolbox.plist"

  if sudo diff "$DOTFILES_PLIST" "$PREFERENCES_PLIST" > /dev/null 2>&1; then
    echo "No differences found between the plist files."
  else
    echo "Differences found between the plist files. Copying..."
    sudo cp "$DOTFILES_PLIST" "$PREFERENCES_PLIST"
    echo "Copied $DOTFILES_PLIST to $PREFERENCES_PLIST."
  fi
fi

# Run nix-darwin switch with flake if macOS
if [ "$OS_TYPE" = "Darwin" ]; then
  nix run nix-darwin -- switch --flake ~/.config/nix-darwin
  darwin-rebuild switch --flake ~/.config/nix-darwin
fi

