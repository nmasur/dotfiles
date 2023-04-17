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
    unfreePackages = [ "obsidian" ];
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [ obsidian ];
    };

    # Broken on 2023-04-16
    nixpkgs.config.permittedInsecurePackages = [ "electron-21.4.0" ];

  };

}
