{ config, pkgs, lib, ... }: {

  options = {
    obsidian = {
      enable = lib.mkEnableOption {
        description = "Enable Obsidian.";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.gui.enable && config.obsidian.enable) {
    unfreePackages = [ pkgs.obsidian ];
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [ obsidian ];
    };
  };

}
