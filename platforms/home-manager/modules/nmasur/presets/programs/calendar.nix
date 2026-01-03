{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.calendar;
in

{

  options.nmasur.presets.programs.calendar = {
    enable = lib.mkEnableOption "Calendar application";
    username = lib.mkOption {
      type = lib.types.str;
      description = "Username for the calendar service backend";
      default = config.nmasur.settings.username;
    };
    hostname = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for the calendar service backend";
    };
    url = lib.mkOption {
      type = lib.types.str;
      description = "Username for the calendar service backend";
      default = "https://${cfg.hostname}/remote.php/dav/principals/users/${cfg.username}";
    };
  };

  config = lib.mkIf cfg.enable {

    accounts.calendar.accounts.default = {
      name = "personal";
      local.type = "filesystem";
      primary = true;
      remote = {
        passwordCommand = [ "" ];
        type = "caldav";
        url = cfg.url;
        userName = cfg.username;
      };
    };

    home.packages = [ pkgs.gnome-calendar ];
  };
}
