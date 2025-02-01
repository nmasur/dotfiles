{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.gaming;
in

{

  options.nmasur.profiles.gaming.enable = lib.mkEnableOption "gaming config for macOS";

  config = lib.mkIf cfg.enable {

    nmasur.profiles.base.enable = lib.mkDefault true;

    homebrew.casks = lib.mkDefault [
      "steam" # Not packaged for Nixon macOS
      "epic-games" # Not packaged for Nix
    ];

  };
}
