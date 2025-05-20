# My Dotfiles

This repository contains my personal dotfiles, configurations, and scripts for
various applications and tools that I use daily. These files are managed using
`stow` and `git`, allowing for easy deployment and version control.

## Table of Contents

- [Features](#features)
- [Prerequisites](#prerequisites)
- [Installation](#installation)
- [Usage](#usage)
- [Contributing](#contributing)

## Features

- **Organized Structure:** Dotfiles are grouped by application or tool for easy
  management.
- **Automated Installation:** A script (`install.sh`) simplifies the setup
  process.
- **Version Controlled:** Tracked with Git for easy updates and rollback.
- **Cross-Platform:** Designed to work on both Linux (specifically NixOS) and
  macOS, with platform-specific configurations where necessary.
- **Stow Management:** Managed with GNU Stow for symlinking configurations to
  the home directory.
- **Neovim Focused:** Heavily customized Neovim setup with plugins and
  configurations for enhanced coding experience.
- **Secure:** Includes configurations for GPG and SSH for secure communication
  and authentication.
- **Clean Shell:** Zsh configuration with syntax highlighting, autosuggestions,
  and a customized Powerlevel10k prompt.

## Prerequisites

Before installing these dotfiles, ensure you have the following tools installed:

- **Git:** For cloning and managing the dotfiles repository.
- **GNU Stow:** For creating symbolic links to the configurations in your home
  directory.
- **Zsh:** As the preferred shell.

Add the ssh keys, and gpg private keys.

## Installation

Follow these steps to install the dotfiles:

1.  **Clone the Repository:**

    ```bash
    git clone --recursive https://github.com/MrZeLee/dotfiles $HOME/.dotfiles
    cd $HOME/.dotfiles
    ```

2.  **Run the Installation Script:**

    ```bash
    ./install.sh
    ```

    The `install.sh` script is under development.

3.  **Configure Stow:**

    After running the installation script, use Stow to symlink the dotfiles into
    your home directory. Navigate to the dotfiles directory and run stow for
    each directory you want to link:

    ```bash
    cd $HOME/.dotfiles
    stow --restow .
    ```

## Usage

After installation, your system should be configured with the dotfiles. If you
make any changes to the dotfiles, remember to:

1.  Commit the changes to the Git repository.
2.  Push the changes to the remote repository.
3.  Use `stow` to update the symlinks in your home directory.

## Contributing

Feel free to fork this repository and submit pull requests with your changes.
Please ensure that your changes are well-documented and follow the existing
directory structure.
