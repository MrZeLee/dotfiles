{ ... } @ args:

let
    # Access the `userSettings` from `specialArgs`
    userSettings = args.userSettings;
in
{
    # import sub modules
    imports = [
        ./core.nix
    ];

    # Home Manager needs a bit of information about you and the
    # paths it should manage.
    home = {
        username = userSettings.username;
        homeDirectory = "/Users/${userSettings.username}";

        # This value determines the Home Manager release that your
        # configuration is compatible with. This helps avoid breakage
        # when a new Home Manager release introduces backwards
        # incompatible changes.
        #
        # You can update Home Manager without changing this value. See
        # the Home Manager release notes for a list of state version
        # changes in each release.
        stateVersion = "24.05";
    };

    # Let Home Manager install and manage itself.
    programs.home-manager.enable = true;

    # Direnv, load and unload environment variables depending on the current directory.
    # https://direnv.net
    # https://rycee.gitlab.io/home-manager/options.html#opt-programs.direnv.enable
    programs.direnv.enable = true;
    programs.direnv.nix-direnv.enable = true;

    # This works.
    home.keyboard = {
        layout = "us";
        variant = "intl";
    };

    targets.darwin.defaults = {
        "com.apple.desktopservices" = {
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
        };  
    };

}
