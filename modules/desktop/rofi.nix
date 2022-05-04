{ config, pkgs, lib, identity, ... }:

{

  config = lib.mkIf config.services.xserver.enable {

    home-manager.users.${identity.user}.programs.rofi = {
      enable = true;
      cycle = true;
      location = "center";
      plugins = [ pkgs.rofi-calc pkgs.rofi-emoji ];
    };
    launcherCommand = "${pkgs.rofi}/bin/rofi -show run";

  };

}

