{ config, pkgs, lib, ... }:

with lib;
let cfg = config.modules.gaming.lutris;

in {

  options.modules.gaming.lutris = { enable = mkEnableOption "lutris"; };

  config = mkIf cfg.enable {
    environment.systemPackages = with pkgs; [ lutris amdvlk wine ];
  };

}
