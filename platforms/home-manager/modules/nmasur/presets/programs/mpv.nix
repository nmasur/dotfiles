{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.mpv;
in

{

  options.nmasur.presets.programs.mpv.enable = lib.mkEnableOption "mpv video player";

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
