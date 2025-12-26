{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.settings;
in

{

  options.nmasur.presets.services.settings.enable = lib.mkEnableOption "macOS settings";

  config = lib.mkIf cfg.enable {

    security.pam.services.sudo_local.touchIdAuth = true;

    system = {

      stateVersion = 5;

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

        # Disable "Are you sure you want to open" dialog
        LaunchServices.LSQuarantine = false;

        # Disable trackpad tap to click
        trackpad.Clicking = false;

        # Where to save screenshots
        screencapture.location = "~/Downloads";

        CustomUserPreferences = {
          # Disable disk image verification
          "com.apple.frameworks.diskimages" = {
            skip-verify = true;
            skip-verify-locked = true;
            skip-verify-remote = true;
          };
          # Require password immediately after screen saver begins
          "com.apple.screensaver" = {
            askForPassword = 1;
            askForPasswordDelay = 0;
          };
        };

        CustomSystemPreferences = {

        };
      };

      # # Settings that don't have an option in nix-darwin
      # activationScripts.postActivation.text = ''
      #   echo "Allow apps from anywhere"
      #   SPCTL=$(spctl --status)
      #   if ! [ "$SPCTL" = "assessments disabled" ]; then
      #       spctl --master-disable
      #   fi
      # '';

    };

  };
}
