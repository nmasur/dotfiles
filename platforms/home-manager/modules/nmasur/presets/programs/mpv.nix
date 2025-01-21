{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.alacritty;
in

{

  options.nmasur.presets.programs.alacritty.enable = lib.mkEnableOption "Alacritty terminal";

  config = lib.mkIf cfg.enable {
    # Video player
    programs.mpv = {
      enable = true;
      bindings = { };
      config = {
        image-display-duration = 2; # For cycling through images
        hwdec = "auto-safe"; # Attempt to use GPU decoding for video
      };
      scripts = [

        # Automatically load playlist entries before and after current file
        pkgs.mpvScripts.autoload

        # Delete current file after quitting
        pkgs.mpvScripts.mpv-delete-file
      ];
    };
  };
}
