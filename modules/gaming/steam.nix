{ config, pkgs, lib, ... }: {

  imports = [ ./. ];

  config = {
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
