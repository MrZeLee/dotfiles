{ config, pkgs, lib, ... }:

let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable)
    # reuse the current configuration
    { config = config.nixpkgs.config; };

  mvdPackage = pkgs.callPackage
    (pkgs.fetchFromGitHub {
      owner = "MrZeLee";
      repo = "mvd";
      rev = "main";
      hash = "sha256-EqWsl3a4ShSf0pTDdblRnfvHf4dkfFB8XCMEw33N0ts=";
    })
    { };

  customWezterm = pkgs.callPackage ./custom/wezterm.nix {
    inherit (pkgs) stdenv rustPlatform lib fetchFromGitHub ncurses perl pkg-config
      python3 fontconfig installShellFiles openssl libGL libxkbcommon wayland zlib
      CoreGraphics Cocoa Foundation System libiconv UserNotifications nixosTests
      runCommand vulkan-loader;

    # Correct X11-related library paths
    libxcb = pkgs.xorg.libxcb;
    libX11 = pkgs.xorg.libX11;
    xcbutil = pkgs.xorg.xcbutil;
    xcbutilimage = pkgs.xorg.xcbutilimage;
    xcbutilkeysyms = pkgs.xorg.xcbutilkeysyms;
    xcbutilwm = pkgs.xorg.xcbutilwm;
  };

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
  fleet-cli = pkgs.buildGoModule rec {
    pname = "fleetcli";
    version = "0.11.3";

    src = pkgs.fetchFromGitHub {
      owner = "rancher";
      repo = "fleet";
      rev = "v${version}";
      sha256 = "sha256-vsm6HD8ThE0TkKzt6aHBGIge9EJViVGQ5rY4iX+wu5U=";
    };

    goModVendor = true;

    vendorHash = "sha256-RZp6zfBG8eseMPtEUSKeCpBL3vKjFLuYvUEo2eeB+gc=";

    testSrc = pkgs.fetchFromGitHub {
      owner = "rancher";
      repo = "fleet-examples";
      rev = "dcf4917293ef131f64724d0c03cadc4f5b257168";
      sha256 = "sha256-le0+a0uHXn4PnZ2avFXb2lcshjNL6YN4Cm6ReLUSlHs=";
    };

    nativeBuildInputs = [ pkgs.git ];
    # buildInputs = [ pkgs.git ];

    buildPhase = ''
      ldflags="-s -w \
      -X github.com/rancher/fleet/pkg/version.Version=${version} \
        -X github.com/rancher/fleet/pkg/version.GitCommit=unknown"
        go build -o ${placeholder "out"}/bin/fleet -ldflags "$ldflags" ./cmd/fleetcli
    '';

    installPhase = ''
      mkdir -p $out/bin
      cp fleet $out/bin/
    '';

    checkPhase = ''
      # Uncomment below to skip tests
      echo "Skipping tests"; exit 0;

      cp -r ${testSrc} fleet-examples
      result=$(./fleet test fleet-examples/simple 2>&1 || true)
      echo "$result" | grep "kind: Deployment"
      versionOutput=$(./fleet --version)
      echo "$versionOutput" | grep "${version}"
    '';

    meta = with pkgs.lib; {
      description = "Manage large fleets of Kubernetes clusters";
      homepage = "https://github.com/rancher/fleet";
      license = licenses.asl20;
    };
  };

  nix-gaming = import (builtins.fetchTarball "https://github.com/fufexan/nix-gaming/archive/master.tar.gz");

  customSwww = pkgs.callPackage ./custom/swww.nix {
    inherit (pkgs) lib fetchFromGitHub rustPlatform pkg-config lz4 libxkbcommon installShellFiles scdoc;
  };

  inherit (pkgs.writers) writeDash;

  hyprctl = "${lib.getExe' pkgs.hyprland "hyprctl"} -i 0";
  # powerprofilesctl = lib.getExe pkgs.power-profiles-daemon;
  notify-send = lib.getExe pkgs.libnotify;
  makoctl = lib.getExe' pkgs.mako "makoctl";
  swww = lib.getExe' customSwww "swww";
  jq_command = lib.getExe pkgs.jq;
  xargs = lib.getExe' pkgs.findutils "xargs";
  pgrep = lib.getExe' pkgs.procps "pgrep";
  pkill = lib.getExe' pkgs.procps "pkill";

  startScript = writeDash "gamemode-start" ''
    ${notify-send} -u low -a 'Gamemode' 'Optimizations activated'
    ${hyprctl} --batch "\
      keyword animations:enabled 0;\
      keyword decoration:shadow:enabled 0;\
      keyword decoration:blur:enabled 0;\
      keyword general:gaps_in 0;\
      keyword general:gaps_out 0;\
      keyword general:border_size 1;\
      keyword decoration:rounding 0;\
      keyword input:kb_layout us_intl_dead_grave_and_dead_tilde_LSGT;\
      keyword input:kb_options caps:none"
    ${hyprctl} devices -j | ${jq_command} -r '.mice.[] | select(.name|test("^.*touchpad.*$")) | .name' | ${xargs} -I _ ${hyprctl} keyword "device[_]:enabled" false
    if ${pgrep} -fx "swww-daemon"; then
      ${pkill} -fx "swww-daemon"
    fi
    if ${pgrep} -fx "^waybar.*"; then
      ${pkill} -fx "^waybar.*"
    fi
    ${makoctl} mode -a 'do-not-disturb'
  '';
  endScript = writeDash "gamemode-end" ''
    ${hyprctl} reload
    ${hyprctl} devices -j | ${jq_command} -r '.mice.[] | select(.name|test("^.*touchpad.*$")) | .name' | ${xargs} -I _ ${hyprctl} keyword "device[_]:enabled" true
    ${makoctl} mode -r 'do-not-disturb'
    ${notify-send} -u low -a 'Gamemode' 'Optimizations deactivated'
  '';

in
{
  programs.gamemode = {
    enable = true;
    settings = {
      general = {
        softrealtime = "auto";
        renice = 15;
      };
      custom = {
        start = startScript.outPath;
        end = endScript.outPath;
      };
    };
  };

  programs.noisetorch.enable = true;

  systemd.user.services.noisetorch = {
    description = "Noisetorch Noise Cancelling";
    after = [ "wireplumber.service" ];

    serviceConfig = {
      Type = "simple";
      RemainAfterExit = "yes";
      ExecStart = "${pkgs.noisetorch}/bin/noisetorch -i -s alsa_input.usb-Macronix_Razer_Barracuda_Pro_2.4_1234-00.mono-fallback -t 95";
      ExecStop = "${pkgs.noisetorch}/bin/noisetorch -u";
      ExecStartPre = "${pkgs.coreutils}/bin/sleep 10s";
    };

    wantedBy = [
      "default.target"
    ];
  };

  imports = [
    nix-gaming.nixosModules.platformOptimizations
    nix-gaming.nixosModules.pipewireLowLatency
  ];

  hardware.steam-hardware.enable = true;

  programs.steam = {
    enable = true;
    remotePlay.openFirewall = true; # Open ports in the firewall for Steam Remote Play
    dedicatedServer.openFirewall = true; # Open ports in the firewall for Source Dedicated Server
    gamescopeSession.enable = false;
    extest.enable = false;
    protontricks.enable = true;
    package = pkgs.steam.override { extraLibraries = pkgs: [ pkgs.gperftools ]; };
  };

  programs.gamescope = {
    enable = true;
    package = pkgs.gamescope;
    args = [
      "--backend wayland"
      "--force-grab-cursor"
      "-W 1920"
      "-H 1080"
      "-r 165"
      "-ef"
    ];
  };

  services.pipewire.lowLatency.enable = true;

  services.gnome.gnome-keyring.enable = true;
  security.pam.services.login.enableGnomeKeyring = true;

  programs.zsh.enable = true;
  programs.zsh.enableGlobalCompInit = false;

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.mrzelee = {
    isNormalUser = true;
    description = "MrZeLee";
    extraGroups = [ "networkmanager" "wheel" "video" "render" "input" "uinput" "gamemode" ];
    home = "/home/mrzelee";
    createHome = true;
    shell = pkgs.zsh;
    useDefaultShell = false;
    packages = with pkgs; [
      # thunderbird
      abook
      ansible
      bat
      brotab
      (if config.hardware.nvidia.modesetting.enable
      then btop.override { cudaSupport = true; }
      else btop)
      # croc - easy send files to another computer
      cacert
      cht-sh
      cloudflared
      croc
      cmake
      coreutils
      ddgr #DuckDuckGo from the terminal.
      eza
      exiftool #Better ls
      gh
      gh-dash
      glow
      gnuplot
      gnupg
      graphviz
      gettext
      home-manager
      isync
      k9s #Kubernetes CLI and TUI To Manage Your Clusters In Style!
      keepassxc
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
      lshw
      msmtp
      maven
      monero-cli
      moreutils
      neomutt
      netcat
      neofetch
      notmuch
      nmap
      opencommit
      opentofu
      (if config.hardware.nvidia.modesetting.enable
      then ollama-cuda
      else ollama)
      # php83
      pass
      python312Packages.pylatexenc
      python312Packages.virtualenv
      rclone
      speedtest-cli
      stow
      tldr
      tree
      tor
      usbutils
      urlscan
      vimv-rs
      watch
      yarn
      yq
      zoxide

      # Nemo file manager
      nemo-with-extensions
      gvfs
      udisks2
      gphoto2
      libmtp
      cinnamon-desktop
      shared-mime-info
      xdg-utils

      # Git
      git-lfs
      tig

      # Neovim
      wl-clipboard
      ## LSP
      lua-language-server
      marksman
      ## img-clip
      # pngpaste # For MacOs
      ## Mason Core
      unzip
      wget
      curl
      gzip
      gnutar # bash sh
      ## Mason Languages
      ###Formatters
      beautysh
      stylua

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
      texliveFull
      ## Treesitter
      tree-sitter
      gcc # nodejs_22 git
      ## Telescope
      ripgrep
      fd
      ## VimTex
      pstree
      xdotool

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
      syncplay
      gnugrep
      gnused
      curl
      mpv
      aria2
      yt-dlp
      ffmpeg_6-full
      fzf
      ani-skip
      gnupatch #iina - installed with homebrew

      #Go-wall - to create wallpapers
      gowall

      #cargo
      cargo
      ## dependencies
      pkg-config
      libgit2
      openssl # clang

      #to take screenshots
      grim
      slurp
      #swayimg optional
      giflib
      libjpeg
      libjxl
      libpng
      librsvg
      libwebp
      libheif
      libavif
      libtiff
      libsixel
      #hyprland optional dependencies
      bc
    ] ++ [
      koji
      mvdPackage
      customWezterm
      fleet-cli
      # pkgs.wezterm
      ## Help Wezterm
      pkgs.mesa
      pkgs.vulkan-loader
      pkgs.vulkan-tools

      # pkgs.discord-canary # krisp not working out of the box
      pkgs.vesktop
      pkgs.spotify

      pkgs.whatsapp-for-linux
      unstable.caprine # messenger facebook
      pkgs.signal-desktop
      pkgs.telegram-desktop

      pkgs.qbittorrent
      pkgs.tor-browser
      pkgs.zathura
      pkgs.zoom-us

      pkgs.swayimg
      pkgs.gimp

      pkgs.seahorse
    ];

    openssh.authorizedKeys.keys = [ "ssh-rsa AAAAB3NzaC1yc2EAAAADAQABAAACAQC2gO7UAKfjRE2uApIneVTMLCpZxL3QkTPTcipAzm3IjTlrjvzvzyXs0+Y0QEFEK9CImH/ZYMBVzb3yJM9o/KeDThbuzfGWP4q18ZVUHvtsPdrNNu/AxUIqhsw+462SGwdju13TnlgXmPfg8bVYHVnJBwXtW/5lZ8lIEZpDHTv2lU3wvOgn3YRVjd8FdfDVGBiad1O6JQEZY7v9BDrg8ynugK4pyt2EViZvaTwQMuZC3EPuDtdrzhCm1oSWPFnA6KEb7musy+0/zR/aV2ewg4Ouy8E69aWiuSV8DPzgVFKT7sj5zEOH8Ouq0AzElQl8XQoJLPHSHFM4qeQE3pAvokFoJAc+I9Wi1ht/PSvZxdiCSAVXT2L9X4G7IN4i4BWaDaEwIFYv9tmxN+DkC6sWWNXNmMSmOJVdisT7GLhvRY70CZgOChg0DBWrcVAynrh6HpRfjQGKi7huHoPxey4YG15+ByKiM25Vi3nRBYwrstsLdVS4SAuoIS4dV8XJ9JVSrFX/fdWRxcjKMcFDgqwzClQ6rmQdqCHkZeTV9CqnehntP3AvVM6xM5bXK4TppJVxE6iJpSBUc01fe0qJLplztYlBeqMZmjdEa/nPjZZMQFE/0TNURI7oCFAGzMgHnxzbLnmSTNjZMi4YpA2BdXREkUh6Cm9UiXAiCjsRoGDaVR0fRw== josel@DESKTOP-JOSE" ];
  };

  # Install firefox.
  programs.firefox = {
    enable = true;
    preferencesStatus = "default";
    preferences = {
      "media.ffmpeg.vaapi.enabled" = true;
      "media.rdd-fmmpeg.enabled" = true;
      "media.av1.enabled" = false;
      "widget.dmabuf.force-enabled" = true;

      "browser.preferences.defaultPerformanceSettings.enabled" = false;
      "browser.translations.automaticallyPopup" = false;
      "signon.rememberSignons" = false;
      "privacy.globalprivacycontrol.enabled" = true;
      "privacy.donottrackheader.enabled" = true;
      "datareporting.healthreport.uploadEnabled" = false;
      "browser.crashReports.unsubmittedCheck.autoSubmit2" = false;
      "network.trr.mode" = 3;
      "browser.sessionstore.restore_on_demand" = false;
    };
  };

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
    #gaming
    mangohud # protonup-qt lutris bottles heroic
  ];

  environment.variables.EDITOR = "nvim";
  environment.shells = [ pkgs.zsh pkgs.bash ];

  fonts = {
    packages = [
      (pkgs.nerdfonts.override { fonts = [ "Hack" ]; }) # Only install Hack Nerd Font
    ];
  };

}

