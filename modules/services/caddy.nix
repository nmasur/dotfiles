{ config, pkgs, lib, ... }:

let

in {

  options = {
    caddyServers = lib.mkOption {
      type = lib.types.attrs;
      description = "Caddy JSON configs for http servers";
    };
  };

  config = {

    services.caddy = {
      enable = true;
      adapter = "''"; # Required to enable JSON
      configFile = pkgs.writeText "Caddyfile"
        (builtins.toJSON { apps.http.servers = config.caddyServers; });

    };

  };

}
