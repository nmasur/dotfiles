{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    slack = {
      enable = lib.mkEnableOption {
        description = "Enable Slack.";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.gui.enable && config.slack.enable) {
    unfreePackages = [ "slack" ];
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [ slack ];
    };
  };

  # Theme string: #1D2122,#665C54,#8EC07C,#BDAE93
}
