{ pkgs, lib, user, gui, ... }:

{
  config = lib.mkIf gui {
    home-manager.users.${user}.home.packages = [ pkgs.firefox ];

    # Required for setting GTK theme (for preferred-color-scheme in browser)
    services.dbus.packages = [ pkgs.dconf ];
    programs.dconf.enable = true;
  };

}
