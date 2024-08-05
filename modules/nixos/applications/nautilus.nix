{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    nautilus = {
      enable = lib.mkEnableOption {
        description = "Enable Nautilus file manager.";
        default = false;
      };
    };
  };

  # Install Nautilus file manager
  config = lib.mkIf (config.gui.enable && config.nautilus.enable) {

    # Quick preview with spacebar
    services.gnome.sushi.enable = true;
    environment.systemPackages = [ pkgs.nautilus ];

    home-manager.users.${config.user} = {

      # Quick button for launching nautilus
      xsession.windowManager.i3.config.keybindings = {
        "${
          config.home-manager.users.${config.user}.xsession.windowManager.i3.config.modifier
        }+n" = "exec --no-startup-id ${pkgs.nautilus}/bin/nautilus";
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

    # Delete Trash files older than 1 week
    systemd.user.services.empty-trash = {
      description = "Empty Trash on a regular basis";
      wantedBy = [ "default.target" ];
      script = "${pkgs.trash-cli}/bin/trash-empty 7";
    };
  };
}
