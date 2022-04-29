{ pkgs, lib, user, gui, gtkTheme, ... }:

{
  config = lib.mkIf gui {
    home-manager.users.${user} = {
      home.packages = [ pkgs.firefox ];
      gtk = {
        enable = true;
        theme = { name = gtkTheme; };
      };
    };

    # Required for setting GTK theme (for preferred-color-scheme in browser)
    services.dbus.packages = [ pkgs.dconf ];
    programs.dconf.enable = true;

  };

}
