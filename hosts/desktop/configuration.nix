# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, lib,... }:
# let
#   home-manager = builtins.fetchTarball "https://github.com/nix-community/home-manager/archive/release-24.11.tar.gz";
# in
let
  unstable = import
    (builtins.fetchTarball https://github.com/nixos/nixpkgs/tarball/nixos-unstable)
    # reuse the current configuration
    { config = config.nixpkgs.config; };

  customWaypaper = pkgs.callPackage ./custom/waypaper.nix {
    inherit (pkgs) lib python3 fetchFromGitHub gobject-introspection wrapGAppsHook3 killall;
  };

  customSwww = pkgs.callPackage ./custom/swww.nix {
    inherit (pkgs) lib fetchFromGitHub rustPlatform pkg-config lz4 libxkbcommon installShellFiles scdoc;
  };
in
{
  imports =
    [ # Include the results of the hardware scan.
      # (import "${home-manager}/nixos")
      ./hardware-configuration.nix
      ./mrzelee.nix
    ];

  # Bootloader.
  boot = {
    consoleLogLevel = 0;
    initrd = {
      verbose = false;
      kernelModules = [ "i915" ];
    };
    plymouth.enable = true;
    loader = {
      efi.canTouchEfiVariables = true;
      # systemd-boot.enable = true;
      grub = {
        enable = true;
        devices = [ "nodev" ];
        efiSupport = true;
        useOSProber = true;
      };
    };
  };

  boot.kernelParams = [
    # General Performance Optimization
    "intel_pstate=active" # Ensures the Intel-specific CPU frequency scaling driver is used for better performance
    "iommu=pt" # Enables IOMMU in pass-through mode, reducing virtualization overhead and ensuring optimal PCIe device performance.

    # NVMe and Storage
    # "nvme_core.default_ps_max_latency_us=0" # Disables NVMe power-saving modes that can cause latency issues.
    # "ahci.mobile_lpm_policy=1" # Reduces power management aggressiveness for SATA AHCI, which may prevent disk disconnects.
    #
    # # Intel CPU Features
    # "nosmt=off" # Ensure hyper-threading (SMT) is enabled unless explicitly disabled for security.
    # "intel_iommu=on" # Enables Intel's IOMMU for better PCIe device handling, particularly useful for virtualization or PCIe passthrough.
    # "idle=nomwait" # Prevents the CPU from entering deep C-states that might cause compatibility issues on some motherboards.
    #
    # # PCI and Interrupt Handling
    # "pcie_aspm=off"
    # "pci=realloc"
    # "pcie_ports=native"
    # ## "pci=nomsi"
    # "pci=nommconf"
    # "pci=noaer"
    #
    # # ACPI and Power Management
    # "acpi=force"
    # "acpi_enforce_resources=lax"
    # "turbostat=1"

    # disable the boot lines
    "quiet"
    "splash"
    "boot.shell_on_fail"
    "i915.fastboot=1"
    "rd.systemd.show_status=false"
    "rd.udev.log_level=3"
    "udev.log_priority=3"

    # "nvidia.NVreg_EnableGpuFirmware=0"
  ];

  hardware.cpu.intel.sgx.provision.enable = true;

  nixpkgs.config.nvidia.acceptLicense = true;

  # Udev rule for NVIDIA device nodes
  # services.udev.extraRules = ''
  #   KERNEL=="nvidia*", MODE="0666"
  # '';

  # programs.uwsm = {
  #  enable = true;
  #  # waylandCompositors = {
  #  #  hyprland = {
  #  #   prettyName = "Hyprland";
  #  #   comment = "Hyprland compositor managed by UWSM";
  #  #   binPath = lib.mkForce "${pkgs.hyprland}/bin/Hyprland";
  #  #  };
  #  #  # sway = {
  #  #  #  prettyName = "Sway";
  #  #  #  comment = "Sway compositor managed by UWSM";
  #  #  #  binPath = lib.mkForce "${pkgs.sway}/bin/sway --unsupported-gpu";
  #  #  # };
  #  # };
  # };

  programs.hyprland = {
    enable = true; # enable Hyprland
    # withUWSM = true; # recommended for most users
    xwayland.enable = true; # Xwayland can be disabled.
    package = pkgs.hyprland.override {
      withSystemd = false;
      debug = false;
    };
  };

  # programs.hyprlock.enable = true;
  # security.pam.services.hyprlock = {};
  services.hypridle.enable = true;
  qt = {
    enable = true;
    platformTheme = "qt5ct";
    style = "adwaita-dark";
  };

  # enable Sway window manager
  programs.sway = {
    enable = true;
    wrapperFeatures.gtk = true;
    xwayland.enable = true;
    extraPackages = with pkgs; [ brightnessctl grim pulseaudio swayidle swaylock fuzzel ];
    extraOptions = [ "--unsupported-gpu" ];
  };

  # Enable OpenGL
  hardware.graphics = {
    enable = true;
    enable32Bit = true;
    # Still don't know if it is doing anything
    extraPackages = with pkgs; [ nvidia-vaapi-driver ];
  };

  programs.gamemode.enable = true;
  programs.gamescope.enable = true;

  # Additional NVIDIA Packages
  environment.systemPackages = with pkgs; [
    egl-wayland # For EGL and Wayland compatibility
    (waybar.overrideAttrs (oldAttrs: {
      patches = (oldAttrs.patches or []) ++ [
        (fetchpatch {
          name = "fix-IPC";
          url = "https://github.com/Alexays/Waybar/commit/dacecb9b265c1c7c36ee43d17526fa95f4e6596f.patch";
          hash = "sha256-9JU4Bw1VXr+3zniF/D1blu2ef9/nb5Q6oKfoxmJ+eQw=";
        })
      ];
    })) # for hyprland
    fuzzel # to search and launch apps
    kitty
    # nautilus # file manager (removed to try nemo)
    gnumake
    grim # screenshot functionality
    slurp # screenshot functionality
    wl-clipboard # wl-copy and wl-paste for copy/paste from stdin / stdout
    mako # notification system developed by swaywm maintainer
    libnotify
    swaylock
    swaybg
    sway-audio-idle-inhibit
    hyprlandPlugins.csgo-vulkan-fix
    hyprlandPlugins.hy3
    pavucontrol #GUI to control audio
    adwaita-icon-theme # cursor theme
  ] ++ [
    customWaypaper
    customSwww
    pkgs.lz4 # for swww animations
    (pkgs.catppuccin-sddm.override {
      flavor = "mocha";
    })
  ];

  environment.sessionVariables = {
    HYPRLAND_CSGO_VULKAN_FIX = "${pkgs.hyprlandPlugins.csgo-vulkan-fix}";
    HYPRLAND_HY3 = "${pkgs.hyprlandPlugins.hy3}";
    HYPRLAND_HOST = "${config.networking.hostName}";
    # LIBVA_DRIVER_NAME = "nvidia";
    # __EGL_VENDOR_LIBRARY_FILENAMES = "/run/opengl-driver/share/glvnd/egl_vendor.d/10_nvidia.json";
  };

  xdg.portal = {
    enable = true;
    extraPortals = [ pkgs.gnome-keyring pkgs.xdg-desktop-portal-gtk ];
  };

  # Enable the X11 windowing system.
  services = {
    libinput = {
      mouse.accelProfile = "flat";
      touchpad.accelProfile = "flat";
      touchpad.naturalScrolling = true;
    };
    xserver = {
      enable = true;
      # Load nvidia driver for Xorg and Wayland
      videoDrivers = [ "nvidia" ];
      xkb = {
        layout = "us";
        variant = "intl";
        model = "pc105";
      };
    };
    displayManager = {
      sddm = {
        enable = true;
        wayland.enable = true;
        package = pkgs.kdePackages.sddm;
        theme = "catppuccin-mocha";
      };
      defaultSession = "hyprland";
    };
    power-profiles-daemon = {
      enable = true;
    };
  };
  
  hardware.nvidia = {

    prime = {
      sync.enable = true;

      intelBusId = "PCI:0:2:0";
      nvidiaBusId = "PCI:1:0:0";
    };

    # Modesetting is required.
    modesetting.enable = true;

    # Nvidia power management. Experimental, and can cause sleep/suspend to fail.
    # Enable this if you have graphical corruption issues or application crashes after waking
    # up from sleep. This fixes it by saving the entire VRAM memory to /tmp/ instead 
    # of just the bare essentials.
    powerManagement.enable = true;

    # Fine-grained power management. Turns off GPU when not in use.
    # Experimental and only works on modern Nvidia GPUs (Turing or newer).
    powerManagement.finegrained = false;

    # Use the NVidia open source kernel module (not to be confused with the
    # independent third-party "nouveau" open source driver).
    # Support is limited to the Turing and later architectures. Full list of 
    # supported GPUs is at: 
    # https://github.com/NVIDIA/open-gpu-kernel-modules#compatible-gpus 
    # Only available from driver 515.43.04+
    # Currently alpha-quality/buggy, so false is currently the recommended setting.
    open = true;

    # Enable the Nvidia settings menu,
	# accessible via `nvidia-settings`.
    nvidiaSettings = true;

    # Optionally, you may need to select the appropriate driver version for your specific GPU.
    package = config.boot.kernelPackages.nvidiaPackages.stable;
  };
  hardware.nvidia-container-toolkit.enable = true;

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
  i18n.defaultLocale = "pt_PT.UTF-8";

  i18n.extraLocaleSettings = {
    LC_MESSAGES = "en_US.UTF-8";
    LC_IDENTIFICATION = "pt_PT.UTF-8";
    LC_CTYPE = "pt_PT.UTF-8";
    LC_COLLATE = "pt_PT.UTF-8";
    LC_TIME = "pt_PT.UTF-8";
    LC_NUMERIC = "pt_PT.UTF-8";
    LC_MONETARY = "pt_PT.UTF-8";
    LC_PAPER = "pt_PT.UTF-8";
    LC_MEASUREMENT = "pt_PT.UTF-8";
    LC_NAME = "pt_PT.UTF-8";
    LC_ADDRESS = "pt_PT.UTF-8";
    LC_TELEPHONE = "pt_PT.UTF-8";
  };

  environment.gnome.excludePackages = (with pkgs; [
    gnome-calendar #calendar
    gnome-calculator
    gnome-clocks
    gnome-maps
    gnome-photos
    gnome-tour
    gnome-music
    gnome-weather
    epiphany # web browser
    geary # email reader
    gnome-characters
    yelp # Help view
    gnome-contacts
    gnome-initial-setup
  ]);

  programs.dconf.enable = true;


  # Disable powermanagement
  powerManagement.enable = false;

  # # Remaps keyboard keys
  # services.evremap = {
  #   enable = true;
  #   settings = {
  #     device_name = "ASUSTeK ROG FALCHION";
  #     dual_role = [
  #                   {
  #                     hold = [
  #                       "KEY_ESC"
  #                     ];
  #                     input = "KEY_CAPSLOCK";
  #                     tap = [
  #                       "KEY_ESC"
  #                     ];
  #                   }
  #                 ];
  #   };
  # };

  # Configure console keymap
  console.keyMap = "us";

  # Enable CUPS to print documents.
  services.printing.enable = true;

  hardware.bluetooth.enable = true; # enables support for Bluetooth
  hardware.bluetooth.powerOnBoot = true; # powers up the default Bluetooth controller on boot

  services.blueman.enable = true;

  # Enable sound with pipewire.
  hardware.pulseaudio.enable = false;
  security.rtkit.enable = true;
  services.pipewire = {
    enable = true;
    alsa.enable = true;
    alsa.support32Bit = true;
    pulse.enable = true;
    # If you want to use JACK applications, uncomment this
    jack.enable = true;

    # use the example session manager (no others are packaged yet so this is enabled by default,
    # no need to redefine it in your config for now)
    #media-session.enable = true;
  };

  # Enable touchpad support (enabled default in most desktopManager).
  # services.xserver.libinput.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # List services that you want to enable:

  services.sshd.enable = true;
  # And expose via SSH
  # programs.ssh.startAgent = true;

  # Enable the OpenSSH daemon.
  services.openssh = {
    enable = true;
    settings = {
      PasswordAuthentication = false;
      KbdInteractiveAuthentication = false;
    };
  };

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
