{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {
    home-manager.users.${config.user} = {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [ discord ];
    };
  };
}
