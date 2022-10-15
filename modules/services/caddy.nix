{ config, pkgs, lib, ... }: {

  options = {
    caddyRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Caddy JSON routes for http servers";
    };
    caddyBlocks = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Caddy JSON error blocks for http servers";
      default = [ ];
    };
  };

  config = {

    services.caddy = {
      enable = true;
      adapter = "''"; # Required to enable JSON
      configFile = pkgs.writeText "Caddyfile" (builtins.toJSON {
        apps.http.servers.main = {
          listen = [ ":443" ];
          routes = config.caddyRoutes;
          errors.routes = config.caddyBlocks;
        };
      });

    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ 443 ];

  };

}
