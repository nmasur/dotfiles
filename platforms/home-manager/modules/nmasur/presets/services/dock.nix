{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.dock;

  # macOS stores persistent-apps as an array of dicts, not strings.
  # nix-darwin's dock module did this transform for us; targets.darwin.defaults
  # writes values verbatim, so we build the tile dicts ourselves.
  mkDockApp = path: {
    tile-data.file-data = {
      _CFURLString = path;
      _CFURLStringType = 0;
    };
  };
in

{

  options.nmasur.presets.services.dock.enable = lib.mkEnableOption "macOS Dock";

  config = lib.mkIf cfg.enable {

    targets.darwin.defaults = {
      "com.apple.dock" = {
        magnification = true;
        largesize = 48;

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

        persistent-apps = map mkDockApp [
          "/Applications/1Password.app"
          "${pkgs.thunderbird}/Applications/Thunderbird.app"
          "${pkgs.slack}/Applications/Slack.app"
          "/System/Applications/Calendar.app"
          "${pkgs.firefox-unwrapped}/Applications/Firefox.app"
          "/System/Applications/Messages.app"
          "/System/Applications/Preview.app"
          "/System/Applications/Mail.app"
          "/Applications/zoom.us.app"
          "${config.programs.ghostty.package}/Applications/Ghostty.app"
          # Discord comes from Homebrew on macOS: the nixpkgs bundle is
          # modified in place, breaking its notarization seal, so macOS 26+
          # refuses to launch it ("damaged"). See presets/programs/homebrew.nix.
          "/Applications/Discord.app"
          "${pkgs.obsidian}/Applications/Obsidian.app"
        ];
      };
    };

    # Automatically reload the Dock and Finder when Home Manager switches
    home.activation = {
      reloadMacSettings = config.lib.dag.entryAfter [ "writeBoundary" ] ''
        verboseEcho "Restarting macOS desktop services..."
        run /usr/bin/killall Dock Finder || true
      '';
    };

  };
}
