{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.gtk;
in

{

  options.nmasur.presets.gtk = {
    enable = lib.mkEnableOption "Gnome GTK settings";
    theme = {
      name = lib.mkOption {
        type = lib.types.str;
        default = "Adwaita-dark";
      };
      package = lib.mkPackageOption pkgs "gnome-themes-extra" { };
    };
  };

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
    gtk = {
      enable = true;
      theme = {
        name = cfg.theme.name;
        package = cfg.theme.package;
      };
      gtk3.extraConfig = {
        gtk-application-prefer-dark-theme = config.theme.mode == "dark";
      };
      gtk4.extraConfig = {
        gtk-application-prefer-dark-theme = config.theme.mode == "dark";
      };
    };

  };

}
