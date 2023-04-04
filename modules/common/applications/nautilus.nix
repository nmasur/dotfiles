{ config, pkgs, lib, ... }: {

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
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [
        gnome.nautilus
        gnome.sushi # Quick preview with spacebar
      ];

      xsession.windowManager.i3.config.keybindings = {
        "${
          config.home-manager.users.${config.user}.xsession.windowManager.i3.config.modifier
        }+n" = "exec --no-startup-id ${pkgs.gnome.nautilus}/bin/nautilus";
      };

      programs.fish.functions = {
        qr = {
          body =
            "${pkgs.qrencode}/bin/qrencode $argv[1] -o /tmp/qr.png | ${pkgs.gnome.sushi}/bin/sushi /tmp/qr.png";
        };
      };

      # Set default for opening directories
      xdg.mimeApps = {
        associations.added."inode/directory" = [ "org.gnome.Nautilus.desktop" ];
        # associations.removed = {
        #   "inode/directory" = [ "kitty-open.desktop" ];
        # };
        defaultApplications."inode/directory" =
          lib.mkBefore [ "org.gnome.Nautilus.desktop" ];
      };
    };

    # # Set default for opening directories
    # xdg.mime = {
    #   addedAssociations."inode/directory" = [ "org.gnome.Nautilus.desktop" ];
    #   removedAssociations = { "inode/directory" = [ "kitty-open.desktop" ]; };
    #   defaultApplications."inode/directory" =
    #     lib.mkForce [ "org.gnome.Nautilus.desktop" ];
    # };

  };

}
