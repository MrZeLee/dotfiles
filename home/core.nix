{ pkgs, lib, mvdPackage, ... } @ args:
let
  # Access the `userSettings` from `specialArgs`
  userSettings = args.userSettings;
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
    cloudflared
    cmake
    coreutils
    glow
    gnuplot
    gnupg
    graphviz
    gettext
    home-manager
    htop
    isync
    kompose
    kubectl
    kubernetes-helm
    kubeseal
    kubetail
    kustomize
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
    speedtest-cli
    stow
    tldr
    tree
    # tor
    urlscan
    watch
    yarn
    yq
    yt-dlp
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
    gcc
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
  ];

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
          KeepAlive = true;
          ProcessType = "Interactive";
          ProgramArguments = [
            "${pkgs.tmux}/bin/tmux"
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
