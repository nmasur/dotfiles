{
  config,
  pkgs,
  lib,
  ...
}:

{

  options.gui.dmenu.enable = lib.mkEnableOption "dmenu launcher.";

  config = lib.mkIf (config.services.xserver.enable && config.dmenu.enable) {

    home-manager.users.${config.user}.home.packages = [ pkgs.dmenu ];
    gui.launcherCommand = "${pkgs.dmenu}/bin/dmenu_run";
  };
}
