{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.services.nextcloud.enable {

    services.nextcloud = {
      package = pkgs.nextcloud27; # Required to specify
      configureRedis = true;
      datadir = "/data/nextcloud";
      database.createLocally = true;
      https = true;
      hostName = "localhost";
      maxUploadSize = "50G";
      config = {
        adminpassFile = config.secrets.nextcloud.dest;
        dbtype = "mysql";
        extraTrustedDomains = [ config.hostnames.content ];
        trustedProxies = [ "127.0.0.1" ];
      };
      extraOptions = { default_phone_region = "US"; };
      extraAppsEnable = true;
      extraApps = with config.services.nextcloud.package.packages.apps; {
        inherit calendar contacts;
        news = pkgs.fetchNextcloudApp {
          url =
            "https://github.com/nextcloud/news/releases/download/22.0.0/news.tar.gz";
          sha256 = "sha256-hhXPEITSbCiFs0o+TOsQnSasXBpjU9mA/OFsbzuaCPw=";
        };
        external = pkgs.fetchNextcloudApp {
          url =
            "https://github.com/nextcloud-releases/external/releases/download/v5.2.0/external-v5.2.0.tar.gz";
          sha256 = "sha256-gY1nxqK/pHfoxW/9mE7DFtNawgdEV7a4OXpscWY14yk=";
        };
        cookbook = pkgs.fetchNextcloudApp {
          url =
            "https://github.com/nextcloud/cookbook/releases/download/v0.10.2/Cookbook-0.10.2.tar.gz";
          sha256 = "sha256-XgBwUr26qW6wvqhrnhhhhcN4wkI+eXDHnNSm1HDbP6M=";
        };
      };
    };

    # Don't let Nginx use main ports (using Caddy instead)
    services.nginx.enable = false;

    services.phpfpm.pools.nextcloud.settings = {
      "listen.owner" = config.services.caddy.user;
      "listen.group" = config.services.caddy.group;
    };
    users.users.caddy.extraGroups = [ "nextcloud" ];

    # Point Caddy to Nginx
    caddy.routes = [{
      match = [{ host = [ config.hostnames.content ]; }];
      handle = [{
        handler = "subroute";
        routes = [
          # Sets variables and headers
          {
            handle = [
              {
                handler = "vars";
                root = config.services.nextcloud.package;
              }
              {
                handler = "headers";
                response.set.Strict-Transport-Security =
                  [ "max-age=31536000;" ];
              }
            ];
          }
          {
            match = [{ path = [ "/nix-apps*" "/store-apps*" ]; }];
            handle = [{
              handler = "vars";
              root = config.services.nextcloud.home;
            }];
          }
          # Reroute carddav and caldav traffic
          {
            match =
              [{ path = [ "/.well-known/carddav" "/.well-known/caldav" ]; }];
            handle = [{
              handler = "static_response";
              headers = { Location = [ "/remote.php/dav" ]; };
              status_code = 301;
            }];
          }
          # Block traffic to sensitive files
          {
            match = [{
              path = [
                "/.htaccess"
                "/data/*"
                "/config/*"
                "/db_structure"
                "/.xml"
                "/README"
                "/3rdparty/*"
                "/lib/*"
                "/templates/*"
                "/occ"
                "/console.php"
              ];
            }];
            handle = [{
              handler = "static_response";
              status_code = 404;
            }];
          }
          # Redirect index.php to the homepage
          {
            match = [{
              file = { try_files = [ "{http.request.uri.path}/index.php" ]; };
              not = [{ path = [ "*/" ]; }];
            }];
            handle = [{
              handler = "static_response";
              headers = { Location = [ "{http.request.orig_uri.path}/" ]; };
              status_code = 308;
            }];
          }
          # Rewrite paths to be relative
          {
            match = [{
              file = {
                split_path = [ ".php" ];
                try_files = [
                  "{http.request.uri.path}"
                  "{http.request.uri.path}/index.php"
                  "index.php"
                ];
              };
            }];
            handle = [{
              handler = "rewrite";
              uri = "{http.matchers.file.relative}";
            }];
          }
          # Send all PHP traffic to Nextcloud PHP service
          {
            match = [{ path = [ "*.php" ]; }];
            handle = [{
              handler = "reverse_proxy";
              transport = {
                protocol = "fastcgi";
                split_path = [ ".php" ];
              };
              upstreams = [{ dial = "unix//run/phpfpm/nextcloud.sock"; }];
            }];
          }
          # Finally, send the rest to the file server
          { handle = [{ handler = "file_server"; }]; }
        ];
      }];
      terminal = true;
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

    # Open to groups, allowing for backups
    systemd.services.phpfpm-nextcloud.serviceConfig.StateDirectoryMode =
      lib.mkForce "0770";

    # Log metrics to prometheus
    networking.hosts."127.0.0.1" = [ config.hostnames.content ];
    services.prometheus.exporters.nextcloud = {
      enable = config.prometheus.exporters.enable;
      username = config.services.nextcloud.config.adminuser;
      url = "https://${config.hostnames.content}";
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
