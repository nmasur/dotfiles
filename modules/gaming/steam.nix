{ config, pkgs, lib, ... }: {

  options.gaming.steam = lib.mkEnableOption "Steam";

  config = lib.mkIf config.gaming.steam {
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
