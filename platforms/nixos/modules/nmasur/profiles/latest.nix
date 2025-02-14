{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.latest;
in

{

  options.nmasur.profiles.latest.enable = lib.mkEnableOption "keeping machine up-to-date";

  config = lib.mkIf cfg.enable {

    # Use latest released Linux kernel by default
    boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;

    nmasur.presets.services.nix-autoupgrade.enable = lib.mkDefault true;

  };
}
