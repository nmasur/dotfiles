{ config, pkgs, lib, ... }: {

  options.gaming.lutris = lib.mkEnableOption "Lutris";

  config = lib.mkIf (config.gaming.lutris || config.gaming.leagueoflegends) {
    environment.systemPackages = with pkgs; [ lutris amdvlk wine ];
  };

}
