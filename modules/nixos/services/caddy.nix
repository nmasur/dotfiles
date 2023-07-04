{ config, pkgs, lib, ... }: {

  options = {
    caddy.tlsPolicies = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Caddy JSON TLS policies";
      default = [ ];
    };
    caddy.routes = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Caddy JSON routes for http servers";
      default = [ ];
    };
    caddy.blocks = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Caddy JSON error blocks for http servers";
      default = [ ];
    };
  };

  config =
    lib.mkIf (config.services.caddy.enable && config.caddy.routes != [ ]) {

      services.caddy = {
        adapter = "''"; # Required to enable JSON
        configFile = pkgs.writeText "Caddyfile" (builtins.toJSON {
          apps.http.servers.main = {
            listen = [ ":443" ];
            routes = config.caddy.routes;
            errors.routes = config.caddy.blocks;
            # logs = { }; # Uncomment to collect access logs
          };
          apps.tls.automation.policies = config.caddy.tlsPolicies;
          logging.logs.main = {
            encoder = { format = "console"; };
            writer = {
              output = "file";
              filename = "${config.services.caddy.logDir}/caddy.log";
              roll = true;
            };
            level = "INFO";
          };
        });

      };

      networking.firewall.allowedTCPPorts = [ 80 443 ];
      networking.firewall.allowedUDPPorts = [ 443 ];

    };

}
