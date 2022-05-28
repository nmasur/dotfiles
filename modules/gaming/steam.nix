{ config, pkgs, lib, ... }: {

  options.gaming.steam = lib.mkEnableOption "Steam";

  config = lib.mkIf config.gaming.steam {
    hardware.steam-hardware.enable = true;
    nixpkgs.config.allowUnfree = true;
    environment.systemPackages = with pkgs; [

      steam

      # Enable terminal interaction
      steamPackages.steamcmd
      steam-tui

    ];
  };

}
