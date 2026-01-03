{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.programs.thunderbird;
in

{

  options.nmasur.presets.programs.thunderbird = {
    enable = lib.mkEnableOption "Thunderbird email client";
    calendar = {
      username = lib.mkOption {
        type = lib.types.str;
        description = "Username for the calendar service backend";
        default = config.nmasur.settings.username;
      };
      passwordCommand = lib.mkOption {
        type = lib.types.str;
        description = "Password for the calendar service backend";
        default = config.accounts.email.accounts.home.passwordCommand;
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for the calendar service backend";
        default = hostnames.content;
      };
      url = lib.mkOption {
        type = lib.types.str;
        description = "URL for the calendar service backend";
        default = "https://${cfg.calendar.hostname}/remote.php/dav";
      };
    };
    tasks = {
      username = lib.mkOption {
        type = lib.types.str;
        description = "Username for the tasks service backend";
        default = config.nmasur.settings.username;
      };
      passwordCommand = lib.mkOption {
        type = lib.types.str;
        description = "Password for the tasks service backend";
        default = "${lib.getExe pkgs.age} --decrypt --identity ~/.ssh/id_ed25519 ${pkgs.writeText "taskspass.age" (builtins.readFile ./taskspass.age)}";
      };
      hostname = lib.mkOption {
        type = lib.types.str;
        description = "Hostname for the tasks service backend";
        default = hostnames.content;
      };
      url = lib.mkOption {
        type = lib.types.str;
        description = "URL for the tasks service backend";
        default = "https://${cfg.tasks.hostname}/remote.php/dav";
      };
    };
  };

  config = lib.mkIf cfg.enable {

    programs.thunderbird = {
      enable = true;
      profiles.default = {
        isDefault = true;
      };
    };
    accounts.email.accounts.home.thunderbird = {
      enable = true;
      profiles = [ "default" ];
    };
    accounts.calendar.basePath = "other/calendars"; # Where to save calendars in ~ directory
    # accounts.calendar.accounts.home = {
    #   local.type = "filesystem";
    #   primary = true;
    #   remote = {
    #     passwordCommand = [ cfg.calendar.passwordCommand ];
    #     type = "caldav";
    #     url = cfg.calendar.url;
    #     userName = cfg.calendar.username;
    #   };
    #   thunderbird = {
    #     enable = true;
    #     profiles = [ "default" ];
    #   };
    # };
    # accounts.calendar.accounts.tasks = {
    #   local.type = "filesystem";
    #   primary = false;
    #   remote = {
    #     passwordCommand = [ cfg.tasks.passwordCommand ];
    #     type = "caldav";
    #     url = cfg.tasks.url;
    #     userName = cfg.tasks.username;
    #   };
    #   thunderbird = {
    #     enable = true;
    #     profiles = [ "default" ];
    #   };
    # };

  };
}
