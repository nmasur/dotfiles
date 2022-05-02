{ config, pkgs, lib, gui, identity, ... }: {

  config = lib.mkIf gui.enable {

    home-manager.users.${identity.user} = {

      home.packages = with pkgs; [ qbittorrent ];

    };
  };

}
