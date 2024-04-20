{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    calibre = {
      enable = lib.mkEnableOption {
        description = "Enable Calibre.";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.gui.enable && config.calibre.enable) {
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [ calibre ];
      # home.sessionVariables = { CALIBRE_USE_DARK_PALETTE = 1; };
    };

    # Forces Calibre to use dark mode
    environment.sessionVariables = {
      CALIBRE_USE_DARK_PALETTE = "1";
    };
  };
}
