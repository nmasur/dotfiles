{ config, pkgs, lib, ... }: {

  options.gaming.steam.enable = lib.mkEnableOption "Steam game launcher.";

  config = lib.mkIf (config.gaming.steam.enable && pkgs.stdenv.isLinux) {
    hardware.steam-hardware.enable = true;
    unfreePackages = [ "steam" "steam-original" "steamcmd" "steam-run" ];
    environment.systemPackages = with pkgs; [

      steam

      # Enable terminal interaction
      steamPackages.steamcmd
      steam-tui

    ];
  };

}
