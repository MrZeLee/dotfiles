{ pkgs, ... } @ args:

  ###################################################################################
  #
  #  macOS's System configuration
  #
  #  All the configuration options are documented here:
  #    https://daiderd.com/nix-darwin/manual/index.html#sec-options
  #  Incomplete list of macOS `defaults` commands :
  #    https://github.com/yannbertrand/macos-defaults
  #
  ###################################################################################
let
    # Access the `userSettings` from `specialArgs`
    userSettings = args.userSettings;
in
{
    system = {
        defaults = {
            ".GlobalPreferences"."com.apple.mouse.scaling" = 1.5;

            NSGlobalDomain = {
                AppleICUForce24HourTime = true;
                AppleInterfaceStyle = "Dark";
                AppleMeasurementUnits = "Centimeters";
                AppleMetricUnits = 1;
                AppleShowAllExtensions = true;
                AppleShowScrollBars = "WhenScrolling";
                AppleTemperatureUnit = "Celsius";
                NSDocumentSaveNewDocumentsToCloud = false;

                InitialKeyRepeat = 15;
                KeyRepeat = 3;

                NSAutomaticCapitalizationEnabled = false;
                NSAutomaticDashSubstitutionEnabled = false;
                NSAutomaticInlinePredictionEnabled = false;
                NSAutomaticPeriodSubstitutionEnabled = false;
                NSAutomaticQuoteSubstitutionEnabled = false;
                NSAutomaticSpellingCorrectionEnabled = false;
                NSAutomaticWindowAnimationsEnabled = false;
                NSDisableAutomaticTermination = false;
                NSNavPanelExpandedStateForSaveMode = true;
                NSNavPanelExpandedStateForSaveMode2 = true;
                NSWindowShouldDragOnGesture = true;
                NSWindowResizeTime = 0.0;
                PMPrintingExpandedStateForPrint = true;
                PMPrintingExpandedStateForPrint2 = true;
                _HIHideMenuBar = true;
                "com.apple.keyboard.fnState" = false;
                "com.apple.mouse.tapBehavior" = 1;
                "com.apple.sound.beep.feedback" = 0;
                "com.apple.sound.beep.volume" = 0.6065307;
                "com.apple.swipescrolldirection" = true;
                "com.apple.trackpad.enableSecondaryClick" = true;
                "com.apple.trackpad.scaling" = 1.0;
                "com.apple.trackpad.trackpadCornerClickBehavior" = null;
            };

            SoftwareUpdate.AutomaticallyInstallMacOSUpdates = false;
            WindowManager.StandardHideDesktopIcons = false;
            alf.stealthenabled = 1;

            dock = {
                autohide = true;
                show-recents = false;

                wvous-bl-corner = 1;
                wvous-br-corner = 1;
                wvous-tl-corner = 1;
                wvous-tr-corner = 1;

                autohide-delay = 0.0;
                autohide-time-modifier = 0.0;
                expose-animation-duration = 0.0;
                expose-group-by-app = false;
                largesize = 64;
                launchanim = false;
                magnification = true;
                orientation = "bottom";
                persistent-apps = [
                    "/System/Applications/Launchpad.app"
                    "/Applications/iTerm.app"
                    "/Applications/Google Chrome.app"
                    "/Applications/Discord.app"
                    "/System/Applications/Messages.app"
                    "/Applications/Spotify.app"
                    "/Applications/KeePassXC.app"
                ];
                persistent-others = [
                    "/Users/${userSettings.username}/Downloads"
                ];
                show-process-indicators = true;
                tilesize = 48;
            };
            
            finder = {
                ShowPathbar = true;
                _FXShowPosixPathInTitle = true;  # show full path in finder title
                AppleShowAllExtensions = true;  # show all file extensions
                FXEnableExtensionChangeWarning = false;  # disable warning when changing file extension
                QuitMenuItem = true;  # enable quit menu item
            };

            loginwindow = {
                GuestEnabled = false;
            };

            screensaver = {
                askForPasswordDelay = 10;
            };
        };

        keyboard = {
            enableKeyMapping = true;
            remapCapsLockToEscape = true;
        };

    };
    # Add ability to used TouchID for sudo authentication
    security.pam.enableSudoTouchIdAuth = true;

    # Create /etc/zshrc that loads the nix-darwin environment.
    # this is required if you want to use darwin's default shell - zsh
    programs.zsh.enable = true;
    environment.shells = [
        pkgs.zsh
    ];
}
