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
            email = "mrzelee123@gmail.com";
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

            services.skhd.enable = true;

            users.users.${userSettings.username}.home = "/Users/${userSettings.username}";
            home-manager.backupFileExtension = "backup";

            # Create /etc/zshrc that loads the nix-darwin environment.
            # this is required if you want to use darwin's default shell - zsh
            programs.zsh.enable = true;
            environment.shells = [
                pkgs.zsh
            ];

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
                configuration
                ./modules/system.nix
                ./modules/nix-core.nix

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

