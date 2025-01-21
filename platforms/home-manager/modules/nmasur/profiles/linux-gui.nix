{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.linux-gui;
in

{

  options.nmasur.profiles.linux-gui.enable = lib.mkEnableOption "Linux GUI home";

  config = lib.mkIf cfg.enable {

    # Cursor
    home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

    # Enable num lock on login
    xsession.numlock.enable = true;

    # Dark theme
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
}
