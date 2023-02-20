{ config, pkgs, lib, ... }: {

  options = {
    _1password = {
      enable = lib.mkEnableOption {
        description = "Enable 1Password.";
        default = false;
      };
    };
  };

  config = lib.mkIf
    (config.gui.enable && config._1password.enable && pkgs.stdenv.isLinux) {
      unfreePackages = [ "1password" "_1password-gui" ];
      home-manager.users.${config.user} = {
        home.packages = with pkgs; [ _1password-gui ];
      };
    };

}
