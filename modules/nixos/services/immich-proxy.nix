{ config, lib, ... }:

{

  options = {
    immich-proxy.enable = lib.mkEnableOption "Immich proxy";
  };

  config = lib.mkIf config.services.immich-proxy.enable {
    caddy.routes = [
      {
        match = [ { host = [ config.hostnames.photosProxy ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "${config.hostnames.photosBackend}:443"; } ];
          }
        ];
      }
    ];
  };

}
