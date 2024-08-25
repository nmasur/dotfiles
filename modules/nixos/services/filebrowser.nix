{
  config,
  pkgs,
  lib,
  ...
}:
let
  user =
    if config.services.nextcloud.enable then
      config.services.phpfpm.pools.nextcloud.user
    else
      "filebrowser";

  dataDir = "/var/lib/filebrowser";

  settings = {
    port = 8020;
    baseURL = "";
    address = "";
    log = "stdout";
    database = "${dataDir}/filebrowser.db";
    root = "";
    "auth.method" = "json";
    username = config.user;
    # Generate password: htpasswd -nBC 10 "" | tr -d ':\n'
    password = "$2y$10$ze1cMob0k6pnXRjLowYfZOVZWg4G.dsPtH3TohbUeEbI0sdkG9.za";
  };

in
{

  options.filebrowser.enable = lib.mkEnableOption "Use Filebrowser.";

  config = lib.mkIf config.filebrowser.enable {

    environment.etc."filebrowser/.filebrowser.json".text = builtins.toJSON settings;

    systemd.services.filebrowser = lib.mkIf config.filebrowser.enable {
      description = "Filebrowser cloud file services";
      after = [ "network.target" ];
      wantedBy = [ "multi-user.target" ];
      startLimitIntervalSec = 14400;
      startLimitBurst = 10;
      serviceConfig = {
        ExecStart = "${pkgs.filebrowser}/bin/filebrowser";
        DynamicUser = !config.services.nextcloud.enable; # Unique user if not using Nextcloud
        User = user;
        Group = user;
        ReadWritePaths = [ dataDir ];
        StateDirectory = [ "filebrowser" ];
        Restart = "on-failure";
        RestartPreventExitStatus = 1;
        RestartSec = "5s";
      };
    };

    caddy.routes = [
      {
        match = [ { host = [ config.hostnames.files ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString settings.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ config.hostnames.files ];

  };

}
