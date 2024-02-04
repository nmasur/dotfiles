{ pkgs, lib, ... }: {

  config = lib.mkIf pkgs.stdenv.isDarwin {

    services.nix-daemon.enable = true;

    # This setting only applies to Darwin, different on NixOS
    nix.gc.interval = {
      Hour = 12;
      Minute = 15;
      Day = 1;
    };

    environment.shells = [ pkgs.fish ];

    security.pam.enableSudoTouchIdAuth = true;

    system = {

      keyboard = {
        remapCapsLockToControl = true;
        enableKeyMapping = true; # Allows for skhd
      };

      defaults = {
        NSGlobalDomain = {

          # Set to dark mode
          AppleInterfaceStyle = "Dark";

          # Don't change from dark to light automatically
          # AppleInterfaceSwitchesAutomatically = false;

          # Enable full keyboard access for all controls (e.g. enable Tab in modal dialogs)
          AppleKeyboardUIMode = 3;

          # Only hide menu bar in fullscreen
          _HIHideMenuBar = false;

          # Expand save panel by default
          NSNavPanelExpandedStateForSaveMode = true;

          # Expand print panel by default
          PMPrintingExpandedStateForPrint = true;

          # Replace press-and-hold with key repeat
          ApplePressAndHoldEnabled = false;

          # Set a fast key repeat rate
          KeyRepeat = 2;

          # Shorten delay before key repeat begins
          InitialKeyRepeat = 12;

          # Save to local disk by default, not iCloud
          NSDocumentSaveNewDocumentsToCloud = false;

          # Disable autocorrect capitalization
          NSAutomaticCapitalizationEnabled = false;

          # Disable autocorrect smart dashes
          NSAutomaticDashSubstitutionEnabled = false;

          # Disable autocorrect adding periods
          NSAutomaticPeriodSubstitutionEnabled = false;

          # Disable autocorrect smart quotation marks
          NSAutomaticQuoteSubstitutionEnabled = false;

          # Disable autocorrect spellcheck
          NSAutomaticSpellingCorrectionEnabled = false;
        };

        dock = {
          # Automatically show and hide the dock
          autohide = true;

          # Add translucency in dock for hidden applications
          showhidden = true;

          # Enable spring loading on all dock items
          enable-spring-load-actions-on-all-items = true;

          # Highlight hover effect in dock stack grid view
          mouse-over-hilite-stack = true;

          mineffect = "genie";
          orientation = "bottom";
          show-recents = false;
          tilesize = 44;
        };

        finder = {

          # Default Finder window set to column view
          FXPreferredViewStyle = "clmv";

          # Finder search in current folder by default
          FXDefaultSearchScope = "SCcf";

          # Disable warning when changing file extension
          FXEnableExtensionChangeWarning = false;

          # Allow quitting of Finder application
          QuitMenuItem = true;

        };

        # Disable "Are you sure you want to open" dialog
        LaunchServices.LSQuarantine = false;

        # Disable trackpad tap to click
        trackpad.Clicking = false;

        # universalaccess = {

        #   # Zoom in with Control + Scroll Wheel
        #   closeViewScrollWheelToggle = true;
        #   closeViewZoomFollowsFocus = true;
        # };

        # Where to save screenshots
        screencapture.location = "~/Downloads";

        CustomUserPreferences = {
          # Disable disk image verification
          "com.apple.frameworks.diskimages" = {
            skip-verify = true;
            skip-verify-locked = true;
            skip-verify-remote = true;
          };
          # Avoid creating .DS_Store files on network or USB volumes
          "com.apple.desktopservices" = {
            DSDontWriteNetworkStores = true;
            DSDontWriteUSBStores = true;
          };
          "com.apple.dock" = {
            magnification = true;
            largesize = 48;
          };
          # Require password immediately after screen saver begins
          "com.apple.screensaver" = {
            askForPassword = 1;
            askForPasswordDelay = 0;
          };
          "com.apple.finder" = {
            # Disable the warning before emptying the Trash
            WarnOnEmptyTrash = false;

            # Finder search in current folder by default
            FXDefaultSearchScope = "SCcf";

            # Default Finder window set to column view
            FXPreferredViewStyle = "clmv";
          };
        };

      };

      # Settings that don't have an option in nix-darwin
      activationScripts.postActivation.text = ''
        echo "Allow apps from anywhere"
        SPCTL=$(spctl --status)
        if ! [ "$SPCTL" = "assessments disabled" ]; then
            sudo spctl --master-disable
        fi
      '';

      # User-level settings
      activationScripts.postUserActivation.text = ''
        echo "Show the ~/Library folder"
        chflags nohidden ~/Library

        echo "Define dock icon function"
        __dock_item() {
            printf "%s%s%s%s%s" \
                   "<dict><key>tile-data</key><dict><key>file-data</key><dict>" \
                   "<key>_CFURLString</key><string>" \
                   "$1" \
                   "</string><key>_CFURLStringType</key><integer>0</integer>" \
                   "</dict></dict></dict>"
        }

        echo "Choose and order dock icons"
        defaults write com.apple.dock persistent-apps -array \
            "$(__dock_item /Applications/1Password.app)" \
            "$(__dock_item ${pkgs.slack}/Applications/Slack.app)" \
            "$(__dock_item /System/Applications/Calendar.app)" \
            "$(__dock_item ${pkgs.firefox-bin}/Applications/Firefox.app)" \
            "$(__dock_item /System/Applications/Messages.app)" \
            "$(__dock_item /System/Applications/Mail.app)" \
            "$(__dock_item /Applications/zoom.us.app)" \
            "$(__dock_item ${pkgs.discord}/Applications/Discord.app)" \
            "$(__dock_item ${pkgs.obsidian}/Applications/Obsidian.app)" \
            "$(__dock_item ${pkgs.kitty}/Applications/kitty.app)" \
            "$(__dock_item /System/Applications/System\ Settings.app)"

        echo "MeetingBar settings"
        defaults write leits.MeetingBar eventTimeFormat -string "\"show\""
        defaults write leits.MeetingBar eventTitleFormat -string "\"none\""
        defaults write leits.MeetingBar eventTitleIconFormat -string "\"iconCalendar\""
        defaults write leits.MeetingBar slackBrowser -string "{\"deletable\":true,\"arguments\":\"\",\"name\":\"Slack\",\"path\":\"\"}"
        defaults write leits.MeetingBar zoomBrowser -string "{\"deletable\":true,\"arguments\":\"\",\"name\":\"Zoom\",\"path\":\"\"}"
        defaults write leits.MeetingBar KeyboardShortcuts_joinEventShortcut -string "{\"carbonModifiers\":6400,\"carbonKeyCode\":38}"
      '';

    };

  };

}
