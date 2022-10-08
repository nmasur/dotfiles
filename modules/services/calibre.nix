{ config, pkgs, lib, ... }:

let

  # Must set group owner to calibre-web
  libraryPath = "/var/books";

in {

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
        calibreLibrary = libraryPath;
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

    # Create directory and set permissions
    systemd.services.calibre-library = {
      requiredBy = [ "calibre-web.service" ];
      before = [ "calibre-web.service" ];
      serviceConfig = {
        Type = "oneshot";
        User = "root";
      };
      script = ''
        mkdir --parents ${libraryPath}
        chown -R calibre-web:calibre-web ${libraryPath}
        chmod 0775 ${libraryPath}
        chmod -R 0640 ${libraryPath}/*
      '';
    };

  };

}
