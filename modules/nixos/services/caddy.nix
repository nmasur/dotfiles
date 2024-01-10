# Caddy is a reverse proxy, like Nginx or Traefik. This creates an ingress
# point from my local network or the public (via Cloudflare). Instead of a
# Caddyfile, I'm using the more expressive JSON config file format. This means
# I can source routes from other areas in my config and build the JSON file
# using the result of the expression.

# Caddy helpfully provides automatic ACME cert generation and management, but
# it requires a form of validation. We are using a custom build of Caddy
# (compiled with an overlay) to insert a plugin for managing DNS validation
# with Cloudflare's DNS API.

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

          # These routes are pulled from the rest of this repo
          routes = config.caddy.routes;
          errors.routes = config.caddy.blocks;

          logs = { }; # Uncommenting collects access logs
        };
        apps.http.servers.metrics = { }; # Enables Prometheus metrics
        apps.tls.automation.policies = config.caddy.tlsPolicies;

        # Setup logging to file
        logging.logs.main = {
          encoder = { format = "console"; };
          writer = {
            output = "file";
            filename = "${config.services.caddy.logDir}/caddy.log";
            roll = true;
            roll_size_mb = 1;
          };
          level = "INFO";
        };

      });

    };

    # Allows Caddy to serve lower ports (443, 80)
    systemd.services.caddy.serviceConfig.AmbientCapabilities =
      "CAP_NET_BIND_SERVICE";

    # Required for web traffic to reach this machine
    networking.firewall.allowedTCPPorts = [ 80 443 ];

    # HTTP/3 QUIC uses UDP (not sure if being used)
    networking.firewall.allowedUDPPorts = [ 443 ];

    # Caddy exposes Prometheus metrics with the admin API
    # https://caddyserver.com/docs/api
    prometheus.scrapeTargets = [ "127.0.0.1:2019" ];

  };

}
