# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports =
    [ # Include the results of the hardware scan.
      ./hardware-configuration.nix
    ];

  networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # Configure network proxy if necessary
  # networking.proxy.default = "http://user:password@proxy:port/";
  # networking.proxy.noProxy = "127.0.0.1,localhost,internal.domain";

  # Enable networking
  networking.networkmanager.enable = true;

  # Set your time zone.
  time.timeZone = "Europe/Lisbon";

  # Select internationalisation properties.
  i18n.defaultLocale = "en_US.UTF-8";

  i18n.extraLocaleSettings = {
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
  };

  # Enable the X11 windowing system.
  services.xserver.enable = true;

  # Enable the GNOME Desktop Environment.
  services.xserver.displayManager.gdm.enable = true;
  services.xserver.displayManager.gdm.autoSuspend = false;
  services.xserver.desktopManager.gnome.enable = true;

  # Set Mouse accelaration Profile
  services.libinput.mouse.accelProfile = "flat";

  # Disable powermanagement
  powerManagement.enable = false;

  # Remaps keyboard keys
  services.evremap = {
    enable = true;
    settings = {
      device_name = "ASUSTeK ROG FALCHION";
      dual_role = [
                    {
                      hold = [
                        "KEY_ESC"
                      ];
                      input = "KEY_CAPSLOCK";
                      tap = [
                        "KEY_ESC"
                      ];
                    }
                  ];
    };
  };

  # Configure keymap in X11
  services.xserver.xkb = {
    layout = "us";
    variant = "alt-intl";
  };

  # Configure console keymap
  console.keyMap = "dvorak";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    #jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

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


  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  # Enable the OpenSSH daemon.
  # services.openssh.enable = true;

  # Open ports in the firewall.
  # networking.firewall.allowedTCPPorts = [ ... ];
  # networking.firewall.allowedUDPPorts = [ ... ];
  # Or disable the firewall altogether.
  # networking.firewall.enable = false;

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "24.11"; # Did you read the comment?

}
