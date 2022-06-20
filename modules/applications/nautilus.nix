{ config, pkgs, lib, ... }: {

  # Install Nautilus file manager
  config = lib.mkIf config.gui.enable {
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [
        gnome.nautilus
        gnome.sushi # Quick preview with spacebar
      ];
    };
  };

}
