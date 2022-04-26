{ config, pkgs, lib, ... }:

with lib;
let cfg = config.modules.gaming.steam;

in {

  options.modules.gaming.steam = { enable = mkEnableOption "steam"; };

  config = mkIf cfg.enable {
    hardware.steam-hardware.enable = true;
    environment.systemPackages = with pkgs; [ steam ];
  };

}
