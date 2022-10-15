{ config, pkgs, lib, ... }: {

  imports = [ ./caddy.nix ];

  options = {
    bookServer = lib.mkOption {
      type = lib.types.str;
      description = "Hostname for Calibre library";
    };
  };

  config = {

    services.calibre-web = {
      enable = true;
      openFirewall = true;
      options = {
        reverseProxyAuth.enable = false;
        enableBookConversion = true;
        enableBookUploading = true;
      };
    };

    # Fix: https://github.com/janeczku/calibre-web/issues/2422
    nixpkgs.overlays = [
      (final: prev: {
        calibre-web = prev.calibre-web.overrideAttrs (old: {
          patches = (old.patches or [ ]) ++ [ ./calibre-web-cloudflare.patch ];
        });
      })
    ];

    caddyRoutes = [{
      match = [{ host = [ config.bookServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:8083"; }];
        headers.request.add."X-Script-Name" = [ "/calibre-web" ];
      }];
    }];

  };

}
