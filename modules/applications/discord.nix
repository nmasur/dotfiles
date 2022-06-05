{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {
    unfreePackages = [ "discord" ];
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [ discord ];
    };
  };
}
