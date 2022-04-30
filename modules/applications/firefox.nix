{ pkgs, lib, identity, gui, ... }:

{
  config = lib.mkIf gui.enable {
    home-manager.users.${identity.user} = {
      home.packages = [ pkgs.firefox ];
      gtk = {
        enable = true;
        theme = { name = gui.gtkTheme; };
      };
    };

    # Required for setting GTK theme (for preferred-color-scheme in browser)
    services.dbus.packages = [ pkgs.dconf ];
    programs.dconf.enable = true;

  };

}
