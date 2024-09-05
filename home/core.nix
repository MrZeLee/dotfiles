{pkgs, ... }:
{
    # list packages installed in system profile. to search by name, run:
    # $ nix-env -qap | grep wget
    home.packages = with pkgs; [
        vimv-rs
        abook
        ansible
        bat
        blueutil
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
        tmux
        tree
        tor
        urlscan
        watch
        wget
        yarn
        yq
        yt-dlp
        zsh
        skhd
        opentofu
        # pkgs.cmake-docs
        # pkgs.fleet-cli
        # pkgs.python312packages.setuptools
        # pkgs.switchaudio-osx
        # johanhaleby/kubetail/kubetail
    ];
}
