{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [ calibre ];
      # home.sessionVariables = { CALIBRE_USE_DARK_PALETTE = 1; };
    };
    environment.sessionVariables = { CALIBRE_USE_DARK_PALETTE = "1"; };
  };
}
