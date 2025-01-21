{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.menubar;
in

{

  options.nmasur.presets.services.menubar.enable = lib.mkEnableOption "macOS menubar settings";

  config = lib.mkIf cfg.enable {

    # User-level settings
    activationScripts.postUserActivation.text = ''
      echo "Reduce Menu Bar padding"
      defaults write -globalDomain NSStatusItemSelectionPadding -int 6
      defaults write -globalDomain NSStatusItemSpacing -int 6
    '';

    system.defaults = {

      # Show seconds on the clock
      menuExtraClock.ShowSeconds = true;

      NSGlobalDomain = {

        # Only hide menu bar in fullscreen
        _HIHideMenuBar = false;

      };

      CustomUserPreferences = {
        "leits.MeetingBar" = {
          eventTimeFormat = ''"show"'';
          eventTitleFormat = ''"none"'';
          eventTitleIconFormat = ''"iconCalendar"'';
          slackBrowser = ''{"deletable":true,"arguments":"","name":"Slack","path":""}'';
          zoomBrowser = ''{"deletable":true,"arguments":"","name":"Zoom","path":""}'';
          teamsBrowser = ''{"deletable":true,"arguments":"","name":"Teams","path":""}'';
          KeyboardShortcuts_joinEventShortcut = ''{"carbonModifiers":6400,"carbonKeyCode":38}'';
          timeFormat = ''"12-hour"'';
        };
      };

    };

  };
}
