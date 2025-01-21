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

  options.nmasur.presets.programs.calendar.enable = lib.mkEnableOption "Calendar application";

  config = lib.mkIf cfg.enable {

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

    home.packages = [ pkgs.gnome-calendar ];
  };
}
