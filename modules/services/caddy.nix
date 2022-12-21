{ config, pkgs, lib, ... }: {

  options = {
    caddy.enable = lib.mkEnableOption "Caddy reverse proxy.";
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

  config = lib.mkIf (config.caddy.enable && config.caddy.routes != [ ]) {

    services.caddy = {
      enable = true;
      adapter = "''"; # Required to enable JSON
      configFile = pkgs.writeText "Caddyfile" (builtins.toJSON {
        apps.http.servers.main = {
          listen = [ ":443" ];
          routes = config.caddy.routes;
          errors.routes = config.caddy.blocks;
        };
      });

    };

    networking.firewall.allowedTCPPorts = [ 80 443 ];
    networking.firewall.allowedUDPPorts = [ 443 ];

  };

}
