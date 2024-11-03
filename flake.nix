{
    description = "MrZeLee Darwin system flake";

    inputs = {
        nixpkgs.url = "github:NixOS/nixpkgs/nixpkgs-unstable";

        nix-darwin.url = "github:LnL7/nix-darwin";
        nix-darwin.inputs.nixpkgs.follows = "nixpkgs";

        # Home Manager
        home-manager.url = "github:nix-community/home-manager/master";
        home-manager.inputs.nixpkgs.follows = "nixpkgs";

        # Add the mvd repository from GitHub
        mvd.url = "github:MrZeLee/mvd";

    };

    outputs = inputs@{
        self,
        nix-darwin,
        nixpkgs,
        home-manager,
        mvd,
        ...
    }: let

        # Automatically select the system based on current machine
        system = builtins.currentSystem;

        pkgs = import nixpkgs { inherit system; };

        # macospkgs = import nixpkgs { system = "aarch64-darwin"; };

        # ---- SYSTEM SETTINGS ---- #
        systemSettingsFn = { system }@attrs: attrs // {
            hostname = builtins.getEnv "HOSTNAME";
            timezone = "Europe/Lisbon";
            locale = "en_US.UTF-8";
        };

        userSettings = rec {
            username = builtins.getEnv "USER";
            name = "MrZeLee";
            email = "mrzelee123@gmail.com";
            dotfilesDir = "~/.dotfiles";
            term = "alacritty";
            editor = "nvim";
            # font = "Hack";
            # fontPkg = macospkgs.nerdfonts;
        };

        # Set Git commit hash for darwin-version.
        configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        stateVersion = 4;

    in
    {
        # Build darwin flake using:
        # $ darwin-rebuild build --flake .#MrZeLees-MacBook-Pro
        darwinConfigurations = {
            "macos" = let
                specialArgs = {
                    inherit userSettings;
                    systemSettings = systemSettingsFn { system = system; };
                    mvdPackage = pkgs.callPackage (mvd + "/default.nix") {};
                };
            in nix-darwin.lib.darwinSystem {

                inherit specialArgs;

                modules = [
                    ./modules/apps.nix
                    ./modules/system.nix
                    ./modules/nix-core.nix
                    {
                        services.skhd.enable = true;
                        users.users.${userSettings.username}.home = "/Users/${userSettings.username}";
                        environment.shells = [ pkgs.zsh ];
                        system.configurationRevision = configurationRevision;
                        system.stateVersion = stateVersion;
                        # Add trusted-users setting here
                        nix.settings = {
                            download-buffer-size = "500M";
                            trusted-users = [ "root" "${userSettings.username}" ];
                        };
                    }

                    home-manager.darwinModules.home-manager {
                        home-manager.useGlobalPkgs = true;
                        # home-manager.useUserPackages = true;
                        home-manager.extraSpecialArgs = specialArgs;
                        home-manager.users.${userSettings.username} = import ./home;
                    }
                ];
            };
        };

        # Expose the package set, including overlays, for convenience.
        darwinPackages = pkgs;
    };
}

