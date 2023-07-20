{ config, pkgs, lib, ... }: {

  options = {
    caddy = {
      tlsPolicies = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        description = "Caddy JSON TLS policies";
        default = [ ];
      };
      routes = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        description = "Caddy JSON routes for http servers";
        default = [ ];
      };
      blocks = lib.mkOption {
        type = lib.types.listOf lib.types.attrs;
        description = "Caddy JSON error blocks for http servers";
        default = [ ];
      };
      cidrAllowlist = lib.mkOption {
        type = lib.types.listOf lib.types.str;
        description = "CIDR blocks to allow for requests";
        default = [ ];
      };
    };
  };

  config = lib.mkIf config.services.caddy.enable {

    # Force Caddy to 403 if not coming from allowlisted source
    caddy.cidrAllowlist = [ "127.0.0.1/32" ];
    caddy.routes = [{
      match = [{ not = [{ remote_ip.ranges = config.caddy.cidrAllowlist; }]; }];
      handle = [{
        handler = "static_response";
        status_code = "403";
      }];
    }];

    services.caddy = {
      adapter = "''"; # Required to enable JSON
      configFile = pkgs.writeText "Caddyfile" (builtins.toJSON {
        apps.http.servers.main = {
          listen = [ ":443" ];
          routes = config.caddy.routes;
          errors.routes = config.caddy.blocks;
          # logs = { }; # Uncomment to collect access logs
        };
        apps.http.servers.metrics = { }; # Enables Prometheus metrics
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

    prometheus.scrapeTargets = [ "127.0.0.1:2019" ];

  };

}
