{ config, pkgs, ... }:

{
    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home.username = "mrzelee";
    home.homeDirectory = "/Users/mrzelee";

    # This value determines the Home Manager release that your
    # configuration is compatible with. This helps avoid breakage
    # when a new Home Manager release introduces backwards
    # incompatible changes.
    #
    # You can update Home Manager without changing this value. See
    # the Home Manager release notes for a list of state version
    # changes in each release.
    home.stateVersion = "24.05";

    # This works.
    home.keyboard = {
        layout = "us";
        variant = "intl";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    targets.darwin.defaults = {
        "com.apple.desktopservices" = {
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
        };  
    };

}
