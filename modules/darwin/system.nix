{ ... }: {
    
  services.nix-daemon.enable = true;

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

        # Automatically show and hide the menu bar
        _HIHideMenuBar = true;

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

    };

    # Settings that don't have an option in nix-darwin
    activationScripts.otherSettings.text = ''
      echo "Disable disk image verification"
      defaults write com.apple.frameworks.diskimages skip-verify -bool true
      defaults write com.apple.frameworks.diskimages skip-verify-locked -bool true
      defaults write com.apple.frameworks.diskimages skip-verify-remote -bool true

      echo "Avoid creating .DS_Store files on network volumes"
      defaults write com.apple.desktopservices DSDontWriteNetworkStores -bool true

      echo "Disable the warning before emptying the Trash"
      defaults write com.apple.finder WarnOnEmptyTrash -bool false

      echo "Require password immediately after sleep or screen saver begins"
      defaults write com.apple.screensaver askForPassword -int 1
      defaults write com.apple.screensaver askForPasswordDelay -int 0

      echo "Show the ~/Library folder"
      chflags nohidden ~/Library && xattr -d com.apple.FinderInfo ~/Library

      echo "Enable dock magnification"
      defaults write com.apple.dock magnification -bool true

      echo "Set dock magnification size"
      defaults write com.apple.dock largesize -int 48

      echo "Choose and order dock icons"
      __dock_item() {
          printf '%s%s%s%s%s' \
                 '<dict><key>tile-data</key><dict><key>file-data</key><dict>' \
                 '<key>_CFURLString</key><string>' \
                 "$1" \
                 '</string><key>_CFURLStringType</key><integer>0</integer>' \
                 '</dict></dict></dict>'
      }

      defaults write com.apple.dock persistent-apps -array \
          "$(__dock_item /Applications/1Password\ 7.app)" \
          "$(__dock_item /Applications/Slack.app)" \
          "$(__dock_item /System/Applications/Calendar.app)" \
          "$(__dock_item /Applications/Firefox.app)" \
          "$(__dock_item /System/Applications/Messages.app)" \
          "$(__dock_item /System/Applications/Mail.app)" \
          "$(__dock_item /Applications/Mimestream.app)" \
          "$(__dock_item /Applications/zoom.us.app)" \
          "$(__dock_item /Applications/Obsidian.app)" \
          "$(__dock_item /Applications/Alacritty.app)" \
          "$(__dock_item /System/Applications/System\ Preferences.app)"

      echo "Turn on Scroll Reverser"
      open /Applications/Scroll\ Reverser.app
      osascript -e 'tell application "System Events" to make login item at end with properties {path:"/Applications/Scroll Reverser.app", hidden:false}'

      echo "Allow apps from anywhere"
      SPCTL=$(spctl --status)
      if ! [ "$SPCTL" = "assessments disabled" ]
      then
          sudo spctl --master-disable
      fi

      echo "Show the ~/Library folder"
      chflags nohidden ~/Library
    '';
  };

}
