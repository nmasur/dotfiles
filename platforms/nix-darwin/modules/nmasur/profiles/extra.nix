{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.extra;
in

{

  options.nmasur.profiles.extra.enable = lib.mkEnableOption "extra config for macOS";

  config = lib.mkIf cfg.enable {

    nmasur.profiles.base.enable = lib.mkDefault true;

    homebrew.casks = lib.mkDefault [
      "keybase" # GUI on Nix not available for macOS
    ];

  };
}
