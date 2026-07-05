{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.menubar;
in

{

  options.nmasur.presets.services.menubar.enable = lib.mkEnableOption "macOS menubar settings";

  config = lib.mkIf cfg.enable {

    home.packages = [
      pkgs.ice-bar # Menu bar hiding
    ];

    targets.darwin.defaults = {
      NSGlobalDomain = {

        # Only hide menu bar in fullscreen
        _HIHideMenuBar = false;

        NSStatusItemSelectionPadding = 6;
        NSStatusItemSpacing = 6;

      };

      "com.apple.menuextra.clock" = {
        # Show seconds on the clock
        ShowSeconds = true;

        FlashDateSeparator = false;
      };

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
}
