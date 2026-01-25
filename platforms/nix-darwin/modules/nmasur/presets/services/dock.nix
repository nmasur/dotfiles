{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.dock;
in

{

  options.nmasur.presets.services.dock.enable = lib.mkEnableOption "macOS Dock";

  config = lib.mkIf cfg.enable {

    nixpkgs.overlays = [
      (_final: _prev: {
        firefox-unwrapped = pkgs.stable.firefox-unwrapped;
      })
    ];

    system.defaults.CustomUserPreferences = {
      "com.apple.dock" = {
        magnification = true;
        largesize = 48;
      };
    };

    system.defaults.dock = {

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

      persistent-apps = [
        "/Applications/1Password.app"
        "${pkgs.slack}/Applications/Slack.app"
        "/System/Applications/Calendar.app"
        "${pkgs.firefox-unwrapped}/Applications/Firefox.app"
        "/System/Applications/Messages.app"
        "/System/Applications/Mail.app"
        "/Applications/zoom.us.app"
        "/Applications/Ghostty.app"
        "${pkgs.discord}/Applications/Discord.app"
        "${pkgs.obsidian}/Applications/Obsidian.app"
      ];
    };
  };
}
