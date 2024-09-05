{
    description = "MrZeLee Darwin system flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

        nix-darwin.url = "github:LnL7/nix-darwin";
        nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

        # Home Manager
        home-manager.url = "github:nix-community/home-manager/master";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

    };

    outputs = inputs@{
        self,
        nix-darwin,
        nixpkgs,
        home-manager,
        ...
    }: let

        # ---- SYSTEM SETTINGS ---- #
        systemSettings = {
            system = "aarch64-darwin"; # system arch
            hostname = "MrZeLees-MacBook-Pro";
            # profile = "personal";
            timezone = "Europe/Lisbon";
            locale = "en_US.UTF-8";
        };

        userSettings = rec {
            username = "mrzelee";
            name = "MrZeLee";
            email = "mrzelee@mrzelee.com";
            dotfilesDir = "~/.dotfiles";
            term = "iterm2";
            # font = "Intel One Mono";
            # fontPkg = pkgs.intel-one-mono;
            editor = "nvim";
        };

        # Set Git commit hash for darwin-version.
        configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        stateVersion = 4;

        configuration = { pkgs, ... }: {
            # List packages installed in system profile. To search by name, run:
            # $ nix-env -qaP | grep wget
            environment.systemPackages = with pkgs; [
                vim
                vimv-rs
                abook
                ansible
                bat
                blueutil
                cacert
                cloudflared
                cmake
                coreutils
                curl
                fzf
                gcc
                git-lfs
                glow
                gnuplot
                gnupg
                graphviz
                gettext
                kubernetes-helm
                htop
                isync
                jq
                kompose
                kubectl
                kubeseal
                kubetail
                kustomize
                libgit2
                lynx
                mas
                maven
                monero
                msmtp
                neomutt
                neovim
                netcat
                notmuch
                nmap
                nodejs_22
                pass
                php83
                pinentry_mac
                pipx
                python312
                ripgrep
                cargo
                rustc
                speedtest-cli
                stow
                tldr
                tmux
                tree
                tor
                urlscan
                vim
                watch
                wget
                yarn
                yq
                yt-dlp
                zsh
                skhd
                opentofu
                # pkgs.cmake-docs
                # pkgs.fleet-cli
                # pkgs.python312Packages.setuptools
                # pkgs.switchaudio-osx
                # johanhaleby/kubetail/kubetail
            ];

            services.skhd.enable = true;

            users.users.${userSettings.username}.home = "/Users/${userSettings.username}";
            home-manager.backupFileExtension = "backup";

            system = {
                # Set Git commit hash for darwin-version.
                configurationRevision = self.rev or self.dirtyRev or null;

                # Used for backwards compatibility, please read the changelog before changing.
                # $ darwin-rebuild changelog
                stateVersion = 4;
            };
        };

        specialArgs = {
            inherit userSettings;
            inherit systemSettings;
        };
    in
    {
        # Build darwin flake using:
        # $ darwin-rebuild build --flake .#MrZeLees-MacBook-Pro
        darwinConfigurations."${systemSettings.hostname}" = nix-darwin.lib.darwinSystem {
            inherit specialArgs;
            modules = [
                ./modules/apps.nix
                ./modules/system.nix
                ./modules/nix-core.nix
                configuration

                home-manager.darwinModules.home-manager {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.extraSpecialArgs = specialArgs;
                    home-manager.users.${userSettings.username} = import ./home;
                }
            ];
        };

        # Expose the package set, including overlays, for convenience.
        darwinPackages = self.darwinConfigurations."${systemSettings.hostname}".pkgs;
    };
}

