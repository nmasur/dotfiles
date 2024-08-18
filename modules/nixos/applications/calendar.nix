{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    calendar = {
      enable = lib.mkEnableOption {
        description = "Enable calendar.";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.gui.enable && config.calendar.enable) {
    home-manager.users.${config.user} = {

      accounts.calendar.accounts.default = {
        basePath = "other/calendars"; # Where to save calendars in ~ directory
        name = "personal";
        local.type = "filesystem";
        primary = true;
        remote = {
          passwordCommand = [ "" ];
          type = "caldav";
          url = "https://${config.hostnames.content}/remote.php/dav/principals/users/${config.user}";
          userName = config.user;
        };
      };

      home.packages = with pkgs; [ gnome-calendar ];
    };
  };
}
