{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.base;
in

{

  options.nmasur.profiles.base.enable = lib.mkEnableOption "base macOS config";

  config = lib.mkIf cfg.enable {

    nmasur.presets.programs = {
      fish.enable = lib.mkDefault true;
      homebrew.enable = lib.mkDefault true;
    };

    homebrew.brews = [
      "trash" # Delete files and folders to trash instead of rm
    ];
    homebrew.casks = [
      "scroll-reverser" # Different scroll style for mouse vs. trackpad
      "notunes" # Don't launch Apple Music with the play button
    ];

  };
}
