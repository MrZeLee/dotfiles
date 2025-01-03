{ pkgs, lib, mvdPackage, ... } @ args:
let
  # Access the `userSettings` from `specialArgs`
  userSettings = args.userSettings;
  koji = pkgs.rustPlatform.buildRustPackage rec {
    pname = "koji";
    version = "3.0.0";

    src = pkgs.fetchFromGitHub {
      owner = "cococonscious";
      repo = "koji";
      rev = "v${version}";
      sha256 = "sha256-v2TptHCnVFJ9DLxki7GP815sosCnDStAzZw7B4g/3mk="; # Replace with actual hash
    };

    cargoHash = "sha256-posT6wp33Tj2bisuYsoh/CK9swS+OVju5vgpj4bTrYs="; # Replace with actual cargo hash

    nativeBuildInputs = with pkgs; [ pkg-config cmake ];
    buildInputs = with pkgs; [ libgit2 openssl ];

    meta = with pkgs.lib; {
      description = "A tool to help create conventional git commits";
      homepage = "https://github.com/koji/koji";
      license = licenses.mit;
      platforms = platforms.unix;
    };
  };
in
{
  # list packages installed in system profile. to search by name, run:
  # $ nix-env -qap | grep wget
  home.packages = with pkgs; [
    vimv-rs
    abook
    ansible
    bat
    brotab
    cacert
    cht-sh
    cloudflared
    croc #Easily and securely send things from one computer to another.
    cmake
    coreutils
    ddgr #DuckDuckGo from the terminal.
    # elinks
    gh
    gh-dash
    glow
    gnuplot
    gnupg
    graphviz
    gettext
    home-manager
    htop
    isync
    k9s #Kubernetes CLI and TUI To Manage Your Clusters In Style!
    kompose
    kubectl
    kubernetes-helm
    kubeseal
    kubetail
    kustomize
    lazygit
    libgit2
    libiconv
    lynx
    mas
    maven
    moreutils
    # monero
    msmtp
    mvdPackage
    neomutt
    netcat
    neofetch
    notmuch
    nmap
    # ollama
    pass
    # php83
    pinentry_mac
    python312Packages.pylatexenc
    python312Packages.virtualenv
    speedtest-cli
    stow
    tldr
    tree
    # tor
    urlscan
    watch
    yarn
    yq
    opentofu

    jankyborders
    eza

    # Git
    opencommit
    git-lfs
    tig

    # Neovim
    ## img-clip
    pngpaste
    ## Mason Core
    unzip
    wget
    curl
    gzip
    gnutar
    ### bash
    ### sh
    ## Mason Languages
    go
    php83
    php83Packages.composer
    lua51Packages.lua
    lua51Packages.luarocks
    julia_19-bin
    python312
    pipx
    rustc
    cargo
    nodejs_22
    ## Treesitter
    tree-sitter
    ### nodejs_22
    ### git
    # gcc ## using clang
    ## Telescope
    ripgrep
    fd

    # Yazi
    yazi
    ## dependencies
    ffmpegthumbnailer
    p7zip
    jq
    poppler
    fd
    ripgrep
    fzf
    zoxide
    imagemagick

    #Ani-cli
    ani-cli
    ## dependencies
    gnugrep
    gnused
    curl
    mpv
    #iina - installed with homebrew
    aria2
    yt-dlp
    ffmpeg_6-full
    fzf
    ani-skip
    gnupatch

    #Go-wall - to create wallpapers
    gowall

    #cargo
    cargo
    ## dependencies
    pkg-config
    libgit2
    clang
    openssl
  ] ++ [ koji ];

  launchd = {
    enable = true;
    agents = {
      borders = {
        enable = true;
        config = {
          Label = "com.example.borders"; # Updated label
          EnvironmentVariables = {
            LANG = "en_US.UTF-8";
            PATH = "${pkgs.jankyborders}/bin:${pkgs.jankyborders}/sbin:/usr/bin:/bin:/usr/sbin:/sbin";
          };
          KeepAlive = true;
          LimitLoadToSessionType = "Aqua";
          ProcessType = "Interactive";
          ProgramArguments = [
            "${pkgs.jankyborders}/bin/borders"
          ];
          RunAtLoad = true;
          StandardErrorPath = "/tmp/borders.err.log";
          StandardOutPath = "/tmp/borders/borders.out.log";
        };
      };
      tmux = {
        enable = true;
        config = {
          Label = "com.example.tmux";
          EnvironmentVariables = {
            LANG = "en_US.UTF-8";
            PATH = "${pkgs.tmux}/bin:/usr/bin:/bin:/usr/sbin:/sbin";
          };
          KeepAlive = false;
          ProcessType = "Interactive";
          ProgramArguments = [
            "${pkgs.tmux}/bin/tmux"
            "new-session" "-d" "-s" "mydaemon"
          ];
          RunAtLoad = true;
          StandardErrorPath = "/tmp/tmux.err.log";
          StandardOutPath = "/tmp/tmux.out.log";
        };
      };
    };
  };


  home = {
    activation = {
      prepareStow = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p /Users/${userSettings.username}/.config
        cd /Users/${userSettings.username}/.dotfiles
        run ${pkgs.stow}/bin/stow -d /Users/${userSettings.username}/.dotfiles -t /Users/${userSettings.username} --restow .
      '';
      brotabInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        run ${pkgs.brotab}/bin/brotab install
        chmod 666 /tmp/brotab.log || true
        chmod 666 /tmp/brotab_mediator.log || true
        mkdir -p /Users/${userSettings.username}/Library/Application\ Support/Mozilla || true
        mkdir -p /Users/${userSettings.username}/Library/Application\ Support/Mozilla/NativeMessagingHosts || true
        ln -sf /Users/${userSettings.username}/.mozilla/native-messaging-hosts/brotab_mediator.json /Users/${userSettings.username}/Library/Application\ Support/Mozilla/NativeMessagingHosts/
      '';
      npmInstall = lib.hm.dag.entryAfter [ "writeBoundary" ] ''
        mkdir -p /Users/${userSettings.username}/.npm-global
      '';
    };
  };
}
