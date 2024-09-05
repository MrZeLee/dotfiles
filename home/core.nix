{pkgs, lib, ... } @ args:
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
        blueutil
        brotab
        cacert
        cloudflared
        cmake
        coreutils
        fzf
        gcc
        git-lfs
        glow
        gnuplot
        gnupg
        graphviz
        gettext
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
        lynx
        mas
        maven
        monero
        msmtp
        neomutt
        netcat
        notmuch
        nmap
        nodejs_22
        pass
        php83
        pinentry_mac
        pipx
        python312
        ripgrep
        cargo
        rustc
        speedtest-cli
        stow
        tldr
        tree
        tor
        urlscan
        watch
        wget
        yarn
        yq
        yt-dlp
        skhd
        opentofu
        # pkgs.cmake-docs
        # pkgs.fleet-cli
        # pkgs.python312packages.setuptools
        # pkgs.switchaudio-osx
        # johanhaleby/kubetail/kubetail
    ];

    home.activation = {
        brotabInstall = lib.hm.dag.entryAfter ["writeBoundary"] ''
            run ${pkgs.brotab}/bin/brotab install
            chmod 666 /tmp/brotab.log || true
            chmod 666 /tmp/brotab_mediator.log || true
            mkdir /Users/${userSettings.username}/Library/Application\ Support/Mozilla || true
            mkdir /Users/${userSettings.username}/Library/Application\ Support/Mozilla/NativeMessagingHosts || true
            ln -sf /Users/${userSettings.username}/.mozilla/native-messaging-hosts/brotab_mediator.json /Users/${userSettings.username}/Library/Application\ Support/Mozilla/NativeMessagingHosts/
        '';
    };
}
