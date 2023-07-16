{ config, pkgs, lib, ... }:

let

  port = 8080;

in {

  config = lib.mkIf config.services.nextcloud.enable {

    services.nextcloud = {
      package = pkgs.nextcloud27; # Required to specify
      datadir = "/data/nextcloud";
      https = true;
      hostName = "localhost";
      maxUploadSize = "50G";
      config = {
        adminpassFile = config.secrets.nextcloud.dest;
        extraTrustedDomains = [ config.hostnames.content ];
        trustedProxies = [ "127.0.0.1" ];
      };
    };

    # Don't let Nginx use main ports (using Caddy instead)
    services.nginx.virtualHosts."localhost".listen = [{
      addr = "127.0.0.1";
      port = port;
    }];

    # Point Caddy to Nginx
    caddy.routes = [{
      match = [{ host = [ config.hostnames.content ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:${builtins.toString port}"; }];
      }];
    }];

    # Create credentials file for nextcloud
    secrets.nextcloud = {
      source = ../../../private/nextcloud.age;
      dest = "${config.secretsDirectory}/nextcloud";
      owner = "nextcloud";
      group = "nextcloud";
      permissions = "0440";
    };
    systemd.services.nextcloud-secret = {
      requiredBy = [ "nextcloud-setup.service" ];
      before = [ "nextcloud-setup.service" ];
    };

    # Grant user access to Nextcloud directories
    users.users.${config.user}.extraGroups = [ "nextcloud" ];

    ## Backup config

    # Open to groups, allowing for backups
    systemd.services.phpfpm-nextcloud.serviceConfig.StateDirectoryMode =
      lib.mkForce "0770";

    # Allow litestream and nextcloud to share a sqlite database
    users.users.litestream.extraGroups = [ "nextcloud" ];
    users.users.nextcloud.extraGroups = [ "litestream" ];

    # Backup sqlite database with litestream
    services.litestream = {
      settings = {
        dbs = [{
          path = "${config.services.nextcloud.datadir}/data/nextcloud.db";
          replicas = [{
            url =
              "s3://${config.backup.s3.bucket}.${config.backup.s3.endpoint}/nextcloud";
          }];
        }];
      };
    };

    # Don't start litestream unless nextcloud is up
    systemd.services.litestream = {
      after = [ "phpfpm-nextcloud.service" ];
      requires = [ "phpfpm-nextcloud.service" ];
    };

    # Log metrics to prometheus
    services.prometheus.exporters.nextcloud = {
      enable = config.prometheus.exporters.enable;
      username = config.services.nextcloud.config.adminuser;
      url = "http://localhost:${builtins.toString port}";
      passwordFile = config.services.nextcloud.config.adminpassFile;
    };
    prometheus.scrapeTargets = [
      "127.0.0.1:${
        builtins.toString config.services.prometheus.exporters.nextcloud.port
      }"
    ];
    # Allows nextcloud-exporter to read passwordFile
    users.users.nextcloud-exporter.extraGroups =
      lib.mkIf config.services.prometheus.exporters.nextcloud.enable
      [ "nextcloud" ];

  };

}
