{
  config,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.hister;
in

{

  options.nmasur.presets.services.hister = {
    enable = lib.mkEnableOption "Hister web history service";
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to use for the localhost";
      default = 4433;
    };
  };

  config = lib.mkIf cfg.enable {

    services.hister = {
      enable = true;
      port = cfg.port;
      settings = {
        app = {
          user_handling = true;
        };
        server = {
          base_url = "https://${hostnames.hister}";
        };
      };
    };

    # Adding new users:
    # sudo -u hister hister --config /run/hister/config.yml create-user <username> --admin

    # Allow web traffic to Caddy
    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.hister ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString cfg.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.hister ];

  };

}
