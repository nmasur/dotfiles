{ config, pkgs, lib, ... }:

let

in {

  options = {
    caddyRoutes = lib.mkOption {
      type = lib.types.listOf lib.types.attrs;
      description = "Caddy JSON routes for http servers";
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
        };
      });

    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ 443 ];

  };

}
