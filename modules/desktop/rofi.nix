{ config, pkgs, lib, ... }:

{

  config = lib.mkIf config.services.xserver.enable {

    home-manager.users.${config.user}.programs.rofi = {
      enable = true;
      cycle = true;
      location = "center";
      plugins = [ pkgs.rofi-calc pkgs.rofi-emoji ];
    };
    gui.launcherCommand = "${pkgs.rofi}/bin/rofi -show run";

  };

}

