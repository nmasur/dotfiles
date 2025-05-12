{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.karakeep;
  inherit (config.nmasur.settings) hostnames;
in

{
  options.nmasur.presets.services.karakeep.enable = lib.mkEnableOption "Karakeep bookmark manager";

  config = lib.mkIf cfg.enable {
    services.karakeep = {
      enable = true;
      meilisearch.enable = true;
      extraEnvironment = {
        PORT = "5599";
        DISABLE_SIGNUPS = "true";
        DISABLE_NEW_RELEASE_CHECK = "true";
        CRAWLER_FULL_PAGE_SCREENSHOT = "true";
        CRAWLER_FULL_PAGE_ARCHIVE = "true";
      };
    };

    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.bookmarks ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              { dial = "localhost:${config.services.karakeep.extraEnvironment.PORT}"; }
            ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.bookmarks ];

  };
}
