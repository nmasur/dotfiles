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

      # Set default for opening directories
      xdg.mimeApps.defaultApplications."inode/directory" =
        [ "nautilus.desktop" ];

      programs.fish.functions = {
        qr = {
          body =
            "${pkgs.qrencode}/bin/qrencode $argv[1] -o /tmp/qr.png | ${pkgs.gnome.sushi}/bin/sushi /tmp/qr.png";
        };
      };
    };
  };

}
