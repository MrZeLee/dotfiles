{ config, pkgs, ... }:

{
  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
  };

  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.josel = {
    isNormalUser = true;
    description = "MrZeLee";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "input" "uinput" ];
    shell = pkgs.zsh;
    useDefaultShell = false;
    packages = with pkgs; [
      lshw
      # thunderbird
      keepassxc
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
      (btop.override { cudaSupport = true; })
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
      maven
      moreutils
      # monero
      msmtp
      # mvdPackage
      neomutt
      netcat
      neofetch
      notmuch
      nmap
      # ollama
      pass
      # php83
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

      eza

      # Git
      opencommit
      git-lfs
      tig

      # Neovim
      wl-clipboard
      ## img-clip
      # pngpaste # For MacOs
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
      python312Packages.pip
      pipx
      rustc
      cargo
      nodejs_23
      zulu23
      texliveMedium
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
    ] ++ [
      pkgs.wezterm
      pkgs.steam
      pkgs.webcord
    ];
  };

  # Install firefox.
  programs.firefox.enable = true;

  # Allow unfree packages
  nixpkgs.config.allowUnfree = true;

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    tmux
    git
    vim # Do not forget to add an editor to edit configuration.nix! The Nano editor is also installed by default.
    wget
    neovim
    zsh
    pinentry-all
    pciutils
    mesa-demos
  ];

  environment.variables.EDITOR = "nvim";
  environment.shells = [ pkgs.zsh pkgs.bash ];

  fonts = {
    packages = [
      (pkgs.nerdfonts.override { fonts = [ "Hack" ]; }) # Only install Hack Nerd Font
    ];
  };

}

