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
      name = lib.mkDefault "Adwaita";
      package = lib.mkDefault pkgs.adwaita-icon-theme;
      size = lib.mkDefault 24;
      gtk.enable = lib.mkDefault true;
      x11.enable = lib.mkDefault true;
    };

    # Enable num lock on login
    xsession.numlock.enable = lib.mkDefault true;

    # Dark theme
    gtk =
      let
        gtkExtraConfig = {
          gtk-application-prefer-dark-theme = lib.mkDefault config.theme.dark;
        };
      in
      {
        enable = lib.mkDefault true;
        theme = {
          name = lib.mkDefault config.gtk.theme.name;
          package = lib.mkDefault config.gtk.theme.package;
        };
        gtk3.extraConfig = lib.mkDefault gtkExtraConfig;
        gtk4.extraConfig = lib.mkDefault gtkExtraConfig;
      };

    programs.zed-editor.enable = lib.mkDefault true;

  };
}
