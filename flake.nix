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

    outputs = inputs@{ self, nix-darwin, nixpkgs, home-manager }:
    let
    configuration = { pkgs, ... }: {
        # List packages installed in system profile. To search by name, run:
        # $ nix-env -qaP | grep wget
        environment.systemPackages = with pkgs; [
            vim
            abook
            ansible
            bat
            blueutil
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
            mas
            maven
            monero
            msmtp
            neomutt
            neovim
            netcat
            nmap
            nodejs_22
            pass
            php
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
            vim
            watch
            wget
            yarn
            yq
            zsh
            skhd
            opentofu
            # pkgs.cmake-docs
            # pkgs.fleet-cli
            # pkgs.python312Packages.setuptools
            # pkgs.switchaudio-osx
            # johanhaleby/kubetail/kubetail
        ];

        # Auto upgrade nix package and the daemon service.
        services.nix-daemon.enable = true;
        # nix.package = pkgs.nix;

        services.skhd.enable = true;

        # Necessary for using flakes on this system.
        nix.settings.experimental-features = "nix-command flakes";

        # Create /etc/zshrc that loads the nix-darwin environment.
        programs.zsh.enable = true;  # default shell on catalina
        environment.shells = [ pkgs.bash pkgs.zsh ];
        environment.loginShell = pkgs.zsh;
        # programs.fish.enable = true;

        # Set Git commit hash for darwin-version.
        system.configurationRevision = self.rev or self.dirtyRev or null;

        # Used for backwards compatibility, please read the changelog before changing.
        # $ darwin-rebuild changelog
        system.stateVersion = 4;

        # The platform the configuration will be used on.
        nixpkgs.hostPlatform = "aarch64-darwin";

        # Enables touchId instead of password in terminal
        security.pam.enableSudoTouchIdAuth = true;

        users.users.mrzelee.home = "/Users/mrzelee";
        home-manager.backupFileExtension = "backup";
        nix.configureBuildUsers = true;
        nix.useDaemon = true;

        # Homebrew needs to be installed on its own!
        homebrew.enable = true;
        homebrew.casks = [
            "adobe-acrobat-reader"
            "adobe-digital-editions"
            "alfred"
            "authy"
            "bartender"
            "calibre"
            "cheatsheet"
            "discord"
            "displaylink"
            "docker"
            "drawio"
            "dropzone"
            "firefox"
            "font-hack-nerd-font"
            "font-source-code-pro"
            "github"
            "google-chrome"
            "google-cloud-sdk"
            "google-drive"
            "iterm2"
            "keepassxc"
            "keyboardcleantool"
            "kobo"
            "mactex-no-gui"
            "mendeley"
            "messenger"
            "mimestream"
            "obs"
            "onionshare"
            "opera"
            "parallels"
            "parallels-toolbox"
            "pdf-expert"
            "private-internet-access"
            "qbittorrent"
            "raspberry-pi-imager"
            "shottr"
            "skim"
            "skype"
            "slack"
            "spotify"
            "telegram"
            "temurin"
            "termius"
            "tor-browser"
            "tunnelblick"
            "typora"
            "visual-studio-code"
            "vlc"
            "whatsapp"
            "wireshark"
            "zoom"
            "nikitabobko/tap/aerospace"
        ];
        homebrew.brews = [
        ];
        homebrew.taps = [
            "nikitabobko/tap"
        ];

        homebrew.masApps = {
            "Print to PDF" = 1639234272;
            "Webcam Settings" = 533696630;
            "Be Focused Pro" = 961632517;
            "Xcode" = 497799835;
            "Chrono Plus" = 946047238;
            "Focus Matrix" = 1087284172;
            "The Unarchiver" = 425424353;
            "LG Screen Manager" = 1142051783;
            "WireGuard" = 1451685025;
        };

        homebrew.onActivation.cleanup = "uninstall";
        homebrew.onActivation.upgrade = true;

        system.defaults.".GlobalPreferences"."com.apple.mouse.scaling" = 1.5;
        system.defaults.NSGlobalDomain.AppleICUForce24HourTime = true;
        system.defaults.NSGlobalDomain.AppleInterfaceStyle = "Dark";
        system.defaults.NSGlobalDomain.AppleMeasurementUnits = "Centimeters";
        system.defaults.NSGlobalDomain.AppleMetricUnits = 1;
        system.defaults.NSGlobalDomain.AppleShowAllExtensions = true;
        system.defaults.NSGlobalDomain.AppleShowScrollBars = "WhenScrolling";
        system.defaults.NSGlobalDomain.AppleTemperatureUnit = "Celsius";
        system.defaults.NSGlobalDomain.NSDocumentSaveNewDocumentsToCloud = false;
        system.defaults.NSGlobalDomain.InitialKeyRepeat = 25;
        system.defaults.NSGlobalDomain.KeyRepeat = 5;
        system.defaults.NSGlobalDomain.NSAutomaticCapitalizationEnabled = false;
        system.defaults.NSGlobalDomain.NSAutomaticDashSubstitutionEnabled = false;
        system.defaults.NSGlobalDomain.NSAutomaticInlinePredictionEnabled = false;
        system.defaults.NSGlobalDomain.NSAutomaticPeriodSubstitutionEnabled = false;
        system.defaults.NSGlobalDomain.NSAutomaticQuoteSubstitutionEnabled = false;
        system.defaults.NSGlobalDomain.NSAutomaticSpellingCorrectionEnabled = false;
        system.defaults.NSGlobalDomain.NSAutomaticWindowAnimationsEnabled = false;
        system.defaults.NSGlobalDomain.NSDisableAutomaticTermination = false;
        system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode = true;
        system.defaults.NSGlobalDomain.NSNavPanelExpandedStateForSaveMode2 = true;
        system.defaults.NSGlobalDomain.NSWindowShouldDragOnGesture = true;
        system.defaults.NSGlobalDomain.NSWindowResizeTime = 0.0;
        system.defaults.NSGlobalDomain.PMPrintingExpandedStateForPrint = true;
        system.defaults.NSGlobalDomain.PMPrintingExpandedStateForPrint2 = true;
        system.defaults.NSGlobalDomain._HIHideMenuBar = true;
        system.defaults.NSGlobalDomain."com.apple.keyboard.fnState" = false;
        system.defaults.NSGlobalDomain."com.apple.mouse.tapBehavior" = 1;
        system.defaults.NSGlobalDomain."com.apple.sound.beep.feedback" = 0;
        system.defaults.NSGlobalDomain."com.apple.sound.beep.volume" = 0.6065307;
        system.defaults.NSGlobalDomain."com.apple.swipescrolldirection" = true;
        system.defaults.NSGlobalDomain."com.apple.trackpad.enableSecondaryClick" = true;
        system.defaults.NSGlobalDomain."com.apple.trackpad.scaling" = 1.0;
        system.defaults.NSGlobalDomain."com.apple.trackpad.trackpadCornerClickBehavior" = null;
        system.defaults.SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
        system.defaults.WindowManager.StandardHideDesktopIcons = false;
        system.defaults.alf.stealthenabled = 1;
        system.defaults.dock.autohide = true;
        system.defaults.dock.autohide-delay = 0.0;
        system.defaults.dock.autohide-time-modifier = 0.0;
        system.defaults.dock.expose-animation-duration = 0.0;
        system.defaults.dock.expose-group-by-app = false;
        system.defaults.dock.largesize = 64;
        system.defaults.dock.launchanim = false;
        system.defaults.dock.magnification = true;
        system.defaults.dock.orientation = "bottom";
        system.defaults.dock.persistent-apps = [
            "/System/Applications/Launchpad.app"
            "/Applications/iTerm.app"
            "/Applications/Google Chrome.app"
            "/Applications/Discord.app"
            "/System/Applications/Messages.app"
            "/Applications/Spotify.app"
            "/Applications/KeePassXC.app"
        ];
        system.defaults.dock.persistent-others = [
            "/Users/mrzelee/Downloads"
        ];
        system.defaults.dock.show-process-indicators = true;
        system.defaults.dock.tilesize = 48;
        system.defaults.dock.wvous-bl-corner = 1;
        system.defaults.dock.wvous-br-corner = 1;
        system.defaults.dock.wvous-tl-corner = 1;
        system.defaults.dock.wvous-tr-corner = 1;
        system.defaults.finder.ShowPathbar = true;
        system.defaults.loginwindow.GuestEnabled = false;
        system.defaults.screensaver.askForPasswordDelay = 10;
        system.keyboard.enableKeyMapping = true;
        system.keyboard.remapCapsLockToEscape = true;

    };
    in
    {
        # Build darwin flake using:
        # $ darwin-rebuild build --flake .#MrZeLees-MacBook-Pro
        darwinConfigurations."MrZeLees-MacBook-Pro" = nix-darwin.lib.darwinSystem {
            modules = [
                configuration
                home-manager.darwinModules.home-manager {
                    home-manager.useGlobalPkgs = true;
                    home-manager.useUserPackages = true;
                    home-manager.users.mrzelee = import ./home.nix;
                }
            ];
        };

        # Expose the package set, including overlays, for convenience.
        darwinPackages = self.darwinConfigurations."MrZeLees-MacBook-Pro".pkgs;
    };
}

