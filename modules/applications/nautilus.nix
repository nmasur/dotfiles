{ config, pkgs, lib, ... }: {

  # Install Nautilus file manager
  config = lib.mkIf config.gui.enable {
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [
        gnome.nautilus
        gnome.sushi # Quick preview with spacebar
      ];

      programs.fish.functions = {
        qr = {
          body =
            "${pkgs.qrencode}/bin/qrencode $argv[1] -o /tmp/qr.png | ${pkgs.gnome.sushi}/bin/sushi /tmp/qr.png";
        };
      };
    };
  };

}
