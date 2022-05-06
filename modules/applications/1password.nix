{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {
    nixpkgs.config.allowUnfree = true;
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [ _1password-gui ];
    };
  };
}
