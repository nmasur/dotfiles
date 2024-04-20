{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    gtk.theme = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Theme name for GTK applications";
      };
      package = lib.mkOption {
        type = lib.types.package;
        description = "Theme package for GTK applications";
        default = pkgs.gnome-themes-extra;
      };
    };
  };

  config = lib.mkIf config.gui.enable {

    home-manager.users.${config.user} = {

      gtk =
        let
          gtkExtraConfig = {
            gtk-application-prefer-dark-theme = config.theme.dark;
          };
        in
        {
          enable = true;
          theme = {
            name = config.gtk.theme.name;
            package = config.gtk.theme.package;
          };
          gtk3.extraConfig = gtkExtraConfig;
          gtk4.extraConfig = gtkExtraConfig;
        };
    };

    # Required for setting GTK theme (for preferred-color-scheme in browser)
    services.dbus.packages = [ pkgs.dconf ];
    programs.dconf.enable = true;

    # Make the login screen dark
    services.xserver.displayManager.lightdm.greeters.gtk.theme = {
      name = config.gtk.theme.name;
      package = config.gtk.theme.package;
    };

    environment.sessionVariables = {
      GTK_THEME = config.gtk.theme.name;
    };
  };
}
