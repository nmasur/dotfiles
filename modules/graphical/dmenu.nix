{ config, pkgs, lib, ... }:

{

  config = lib.mkIf config.services.xserver.enable {

    home-manager.users.${config.user}.home.packages = [ pkgs.dmenu ];
    gui.launcherCommand = "${pkgs.dmenu}/bin/dmenu_run";

  };

}
