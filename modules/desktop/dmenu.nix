{ config, pkgs, lib, identity, ... }:

{

  config = lib.mkIf config.services.xserver.enable {

    home-manager.users.${identity.user}.home.packages = [ pkgs.dmenu ];
    launcherCommand = "${pkgs.dmenu}/bin/dmenu_run";

  };

}
