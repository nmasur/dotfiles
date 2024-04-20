{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    qbittorrent = {
      enable = lib.mkEnableOption {
        description = "Enable qBittorrent.";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.gui.enable && config.qbittorrent.enable) {

    home-manager.users.${config.user} = {

      home.packages = with pkgs; [ qbittorrent ];
    };
  };
}
