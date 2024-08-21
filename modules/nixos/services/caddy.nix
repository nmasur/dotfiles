# Caddy is a reverse proxy, like Nginx or Traefik. This creates an ingress
# point from my local network or the public (via Cloudflare). Instead of a
# Caddyfile, I'm using the more expressive JSON config file format. This means
# I can source routes from other areas in my config and build the JSON file
# using the result of the expression.

# Caddy helpfully provides automatic ACME cert generation and management, but
# it requires a form of validation. We are using a custom build of Caddy
# (compiled with an overlay) to insert a plugin for managing DNS validation
# with Cloudflare's DNS API.

{
  config,
  pkgs,
  lib,
  ...
}:
{

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
    caddy.routes = lib.mkBefore [
      {
        match = [ { not = [ { remote_ip.ranges = config.caddy.cidrAllowlist; } ]; } ];
        handle = [
          {
            handler = "static_response";
            status_code = "403";
          }
        ];
      }
    ];

    services.caddy =
      let
        default_logger_name = "other";
        roll_size_mb = 25;
        # Extract list of hostnames (fqdns) from current caddy routes
        getHostnameFromMatch = match: if (lib.hasAttr "host" match) then match.host else [ ];
        getHostnameFromRoute =
          route:
          if (lib.hasAttr "match" route) then (lib.concatMap getHostnameFromMatch route.match) else [ ];
        hostnames_non_unique = lib.concatMap getHostnameFromRoute config.caddy.routes;
        hostnames = lib.unique hostnames_non_unique;
        # Create attrset of subdomains to their fqdns
        hostname_map = builtins.listToAttrs (
          map (hostname: {
            name = builtins.head (lib.splitString "." hostname);
            value = hostname;
          }) hostnames
        );
      in
      {
        adapter = "''"; # Required to enable JSON
        configFile = pkgs.writeText "Caddyfile" (
          builtins.toJSON {
            apps.http.servers.main = {
              listen = [ ":443" ];

              # These routes are pulled from the rest of this repo
              routes = config.caddy.routes;
              errors.routes = config.caddy.blocks;

              # Uncommenting collects access logs
              logs = {
                inherit default_logger_name;
                # Invert hostnames keys and values
                logger_names = lib.mapAttrs' (name: value: {
                  name = value;
                  value = name;
                }) hostname_map;
              };
            };
            apps.http.servers.metrics = { }; # Enables Prometheus metrics
            apps.tls.automation.policies = config.caddy.tlsPolicies;

            # Setup logging to journal and files
            logging.logs =
              {
                # System logs and catch-all
                # Must be called `default` to override Caddy's built-in default logger
                default = {
                  level = "INFO";
                  encoder.format = "console";
                  writer = {
                    output = "stderr";
                  };
                  exclude = (map (hostname: "http.log.access.${hostname}") (builtins.attrNames hostname_map)) ++ [
                    "http.log.access.${default_logger_name}"
                  ];
                };
                # This is for the default access logs (anything not captured by hostname)
                other = {
                  level = "INFO";
                  encoder.format = "json";
                  writer = {
                    output = "file";
                    filename = "${config.services.caddy.logDir}/other.log";
                    roll = true;
                    inherit roll_size_mb;
                  };
                  include = [ "http.log.access.${default_logger_name}" ];
                };
                # This is for using the Caddy API, which will probably never happen
                admin = {
                  level = "INFO";
                  encoder.format = "json";
                  writer = {
                    output = "file";
                    filename = "${config.services.caddy.logDir}/admin.log";
                    roll = true;
                    inherit roll_size_mb;
                  };
                  include = [ "admin" ];
                };
                # This is for TLS cert management tracking
                tls = {
                  level = "INFO";
                  encoder.format = "json";
                  writer = {
                    output = "file";
                    filename = "${config.services.caddy.logDir}/tls.log";
                    roll = true;
                    inherit roll_size_mb;
                  };
                  include = [ "tls" ];
                };
                # This is for debugging
                debug = {
                  level = "DEBUG";
                  encoder.format = "json";
                  writer = {
                    output = "file";
                    filename = "${config.services.caddy.logDir}/debug.log";
                    roll = true;
                    roll_keep = 1;
                    inherit roll_size_mb;
                  };
                };
              }
              # These are the access logs for individual hostnames
              // (lib.mapAttrs (name: value: {
                level = "INFO";
                encoder.format = "json";
                writer = {
                  output = "file";
                  filename = "${config.services.caddy.logDir}/${name}-access.log";
                  roll = true;
                  inherit roll_size_mb;
                };
                include = [ "http.log.access.${name}" ];
              }) hostname_map)
              # We also capture just the errors separately for easy debugging
              // (lib.mapAttrs' (name: value: {
                name = "${name}-error";
                value = {
                  level = "ERROR";
                  encoder.format = "json";
                  writer = {
                    output = "file";
                    filename = "${config.services.caddy.logDir}/${name}-error.log";
                    roll = true;
                    inherit roll_size_mb;
                  };
                  include = [ "http.log.access.${name}" ];
                };
              }) hostname_map);
          }
        );
      };

    systemd.services.caddy.serviceConfig = {

      # Allows Caddy to serve lower ports (443, 80)
      AmbientCapabilities = "CAP_NET_BIND_SERVICE";

      # Prevent flooding of logs by rate-limiting
      LogRateLimitIntervalSec = "5s"; # Limit period
      LogRateLimitBurst = 100; # Limit threshold

    };

    # Required for web traffic to reach this machine
    networking.firewall.allowedTCPPorts = [
      80
      443
    ];

    # HTTP/3 QUIC uses UDP (not sure if being used)
    networking.firewall.allowedUDPPorts = [ 443 ];

    # Caddy exposes Prometheus metrics with the admin API
    # https://caddyserver.com/docs/api
    prometheus.scrapeTargets = [ "127.0.0.1:2019" ];
  };
}
