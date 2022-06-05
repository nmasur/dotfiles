{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {
    unfreePackages = [ "1password" "_1password-gui" ];
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [ _1password-gui ];
    };
  };
}
