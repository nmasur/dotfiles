{
  config,
  pkgs,
  lib,
  ...
}:
let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.services.filebrowser;

  dataDir = "/var/lib/filebrowser";

  settings = {
    port = 8020;
    baseURL = "";
    address = "";
    log = "stdout";
    database = "${dataDir}/filebrowser.db";
    root = "";
    "auth.method" = "json";
    username = username;
    # Generate password: htpasswd -nBC 10 "" | tr -d ':\n'
    password = cfg.passwordHash;
  };

in
{

  options.nmasur.services.filebrowser = {
    enable = lib.mkEnableOption "Filebrowser private files";
    passwordHash = lib.mkOption {
      type = lib.types.str;
      description = ''Hashed password created from htpasswd -nBC 10 "" | tr -d ':\n' '';
    };
  };

  config = lib.mkIf cfg.enable {

    environment.etc."filebrowser/.filebrowser.json".text = builtins.toJSON settings;

    systemd.services.filebrowser = {
      description = "Filebrowser cloud file services";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      startLimitIntervalSec = 14400;
      startLimitBurst = 10;
      serviceConfig = {
        ExecStart = "${pkgs.filebrowser}/bin/filebrowser";
        DynamicUser = true;
        Group = "shared";
        ReadWritePaths = [ dataDir ];
        StateDirectory = [ "filebrowser" ];
        Restart = "on-failure";
        RestartPreventExitStatus = 1;
        RestartSec = "5s";
      };
      path = [ pkgs.getent ]; # Fix: getent not found in $PATH
    };

  };

}
