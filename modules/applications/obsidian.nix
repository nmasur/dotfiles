{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {
    unfreePackages = [ "obsidian" ];
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [ obsidian ];
    };
  };

}
