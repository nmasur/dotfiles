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

    homebrew.brews = lib.mkDefault [
      "trash" # Delete files and folders to trash instead of rm
    ];
    homebrew.casks = lib.mkDefault [
      "scroll-reverser" # Different scroll style for mouse vs. trackpad
      "notunes" # Don't launch Apple Music with the play button
    ];

  };
}
