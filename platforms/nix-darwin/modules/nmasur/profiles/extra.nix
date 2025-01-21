{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.gaming;
in

{

  options.nmasur.profiles.gaming.enable = lib.mkEnableOption "extra config for macOS";

  config = lib.mkIf cfg.enable {

    homebrew.casks = lib.mkDefault [
      "keybase" # GUI on Nix not available for macOS
    ];

  };
}
