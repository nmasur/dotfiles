{ config, pkgs, lib, ... }:

{
  config = lib.mkIf config.gui.enable {
    home-manager.users.${config.user} = {
      home.packages = [ pkgs.firefox ];
      gtk = {
        enable = true;
        theme = { name = config.gui.gtkTheme; };
      };
    };

    # Required for setting GTK theme (for preferred-color-scheme in browser)
    services.dbus.packages = [ pkgs.dconf ];
    programs.dconf.enable = true;

  };

}
