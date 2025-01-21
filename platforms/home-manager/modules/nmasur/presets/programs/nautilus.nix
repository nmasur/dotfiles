{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.nautilus;
in

{

  options.nmasur.presets.programs.nautilus.enable =
    lib.mkEnableOption "Nautilus file manager for Linux";

  config = lib.mkIf cfg.enable {

    # Quick button for launching nautilus
    xsession.windowManager.i3.config.keybindings = {
      "${config.home-manager.users.${config.user}.xsession.windowManager.i3.config.modifier}+n" =
        "exec --no-startup-id ${pkgs.nautilus}/bin/nautilus";
    };

    # Generates a QR code and previews it with sushi
    programs.fish.functions = {
      qr = {
        body = "${pkgs.qrencode}/bin/qrencode $argv[1] -o /tmp/qr.png | ${pkgs.sushi}/bin/sushi /tmp/qr.png";
      };
    };

    # Set Nautilus as default for opening directories
    xdg.mimeApps = {
      associations.added."inode/directory" = [ "org.gnome.Nautilus.desktop" ];
      defaultApplications."inode/directory" = lib.mkBefore [ "org.gnome.Nautilus.desktop" ];
    };
  };
}
