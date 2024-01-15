# Paperless-ngx is a document scanning and management solution.

{ config, lib, ... }: {

  config = lib.mkIf config.services.paperless.enable {

    services.paperless = {
      mediaDir = "/data/generic/paperless";
      passwordFile = config.secrets.paperless.dest;
      settings = {
        PAPERLESS_OCR_USER_ARGS =
          builtins.toJSON { invalidate_digital_signatures = true; };

        # Enable if changing the path name in Caddy
        # PAPERLESS_FORCE_SCRIPT_NAME = "/paperless";
        # PAPERLESS_STATIC_URL = "/paperless/static/";
      };
    };

    users.users.paperless.extraGroups = [ "generic" ];

    caddy.routes = [{
      match = [{
        host = [ config.hostnames.paperless ];
        # path = [ "/paperless*" ]; # Change path name in Caddy
      }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{
          dial =
            "localhost:${builtins.toString config.services.paperless.port}";
        }];
      }];
    }];

    secrets.paperless = {
      source = ../../../private/prometheus.age;
      dest = "${config.secretsDirectory}/paperless";
      owner = "paperless";
      group = "paperless";
      permissions = "0440";
    };
    systemd.services.paperless-secret = {
      requiredBy = [ "paperless.service" ];
      before = [ "paperless.service" ];
    };

  };

}
