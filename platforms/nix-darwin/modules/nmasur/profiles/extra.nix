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

    homebrew.casks = [
      "keybase" # GUI on Nix not available for macOS
    ];

    nix.linux-builder = {
      enable = true;
      systems = [
        "x86_64-linux"
        "aarch64-linux"
      ];
    };

  };
}
