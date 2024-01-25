{ config, pkgs, lib, ... }: {

  options = {
    _1password = {
      enable = lib.mkEnableOption {
        description = "Enable 1Password.";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.gui.enable && config._1password.enable) {
    unfreePackages = [ "1password" "_1password-gui" "1password-cli" ];
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [ _1password-gui ];
    };

    # https://1password.community/discussion/135462/firefox-extension-does-not-connect-to-linux-app
    # Doesn't seem to fix the issue on macOS anyway
    environment.etc."1password/custom_allowed_browsers".text = ''
      ${config.home-manager.users.${config.user}.programs.firefox.package}
      firefox
    '';
  };

}
