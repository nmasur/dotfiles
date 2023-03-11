{ config, pkgs, lib, ... }: {

  options.gaming.steam.enable = lib.mkEnableOption "Steam game launcher.";

  config = lib.mkIf (config.gaming.steam.enable && pkgs.stdenv.isLinux) {
    hardware.steam-hardware.enable = true;
    unfreePackages = with pkgs; [ steam steamcmd steam-run ];

    programs.steam = {
      enable = true;
      remotePlay.openFirewall = true;
    };

    environment.systemPackages = with pkgs; [

      # Enable terminal interaction
      steamPackages.steamcmd
      steam-tui

    ];

  };

}
