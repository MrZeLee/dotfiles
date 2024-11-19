{ pkgs, pkgs-unstable, ... }: {

    ##########################################################################
    # 
    #  Install all apps and packages here.
    #
    #  NOTE: Your can find all available options in:
    #    https://daiderd.com/nix-darwin/manual/index.html
    # 
    # TODO Fell free to modify this file to fit your needs.
    #
    ##########################################################################

    # Install packages from nix's official package repository.
    #
    # The packages installed here are available to all users, and are reproducible across machines, and are rollbackable.
    # But on macOS, it's less stable than homebrew.
    #
    # Related Discussion: https://discourse.nixos.org/t/darwin-again/29331
    environment.systemPackages = [
        pkgs.curl
        pkgs-unstable.vim
        pkgs-unstable.neovim
        pkgs.git
        pkgs.tmux
        pkgs.zsh
    ];
    environment.variables.EDITOR = "nvim";

    fonts = {
        packages = [
            (pkgs.nerdfonts.override { fonts = ["Hack"]; }) # Only install Hack Nerd Font
        ];
    };

    # Homebrew needs to be installed on its own!
    homebrew = {
        enable = true;
        casks = [
            "adobe-acrobat-reader"
            "adobe-digital-editions"
            "alacritty"
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
            # "font-source-code-pro"
            "github"
            "google-chrome"
            "google-cloud-sdk"
            "google-drive"
            # "iterm2"
            "karabiner-elements"
            "keepassxc"
            "keyboardcleantool"
            "kobo"
            "mactex-no-gui"
            "mendeley"
            "messenger"
            "mimestream"
            "obs"
            "ollama"
            "onionshare"
            "opera"
            "openemu"
            # "parallels"
            # "parallels-toolbox"
            "pdf-expert"
            "plex"
            "private-internet-access"
            "qbittorrent"
            "raspberry-pi-imager"
            "shottr"
            "skim"
            "skype"
            "slack"
            "spotify"
            "steam"
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
            "zerotier-one"
            "zoom"
            "nikitabobko/tap/aerospace"
        ];
        brews = [
            "blueutil"
            "fleet-cli"
            "fzf"
            "mpg123"
            "monero"
            "tor"
            "wireguard-tools"
        ];
        taps = [
            "nikitabobko/tap"
            "FelixKratz/formulae"
            "homebrew/services"
        ];
        masApps = {
            "Print to PDF" = 1639234272;
            "Webcam Settings" = 533696630;
            "Be Focused Pro" = 961632517;
            "Xcode" = 497799835;
            "Chrono Plus" = 946047238;
            "Focus Matrix" = 1087284172;
            "The Unarchiver" = 425424353;
            # removed temp to test BetterScreen
            # "LG Screen Manager" = 1142051783;
            "WireGuard" = 1451685025;
        };
        onActivation = {
            cleanup = "uninstall";
            upgrade = true;
        };
    };
}
