{ pkgs, ... }: {

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
    environment.systemPackages = with pkgs; [
        curl
        vim
        neovim
        git
        tmux
        zsh
    ];
    environment.variables.EDITOR = "nvim";

    # Homebrew needs to be installed on its own!
    homebrew = {
        enable = true;
        casks = [
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
            "karabiner-elements"
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
            "openemu"
            "parallels"
            "parallels-toolbox"
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
            "zoom"
            "nikitabobko/tap/aerospace"
        ];
        brews = [
            "blueutil"
            "fzf"
            "php"
            {
                name = "borders";
                start_service = true;
                restart_service = "changed";
            }
            "mpg123"
            "monero"
            "tor"
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
