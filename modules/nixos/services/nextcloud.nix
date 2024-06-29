{
  config,
  pkgs,
  lib,
  ...
}:
{

  config = lib.mkIf config.services.nextcloud.enable {

    services.nextcloud = {
      package = pkgs.nextcloud29; # Required to specify
      configureRedis = true;
      datadir = "/data/nextcloud";
      database.createLocally = true;
      https = true;
      hostName = "localhost";
      maxUploadSize = "50G";
      config = {
        adminpassFile = config.secrets.nextcloud.dest;
        dbtype = "pgsql";
      };
      settings = {
        default_phone_region = "US";
        # Allow access when hitting either of these hosts or IPs
        trusted_domains = [ config.hostnames.content ];
        trusted_proxies = [ "127.0.0.1" ];
        maintenance_window_start = 4; # Run jobs at 4am UTC
        log_type = "file";
        loglevel = 1; # Include all actions in the log
      };
      extraAppsEnable = true;
      extraApps = {
        calendar = config.services.nextcloud.package.packages.apps.calendar;
        contacts = config.services.nextcloud.package.packages.apps.contacts;
        # These apps are defined and pinned by overlay in flake.
        news = pkgs.nextcloudApps.news;
        external = pkgs.nextcloudApps.external;
        cookbook = pkgs.nextcloudApps.cookbook;
        snappymail = pkgs.nextcloudApps.snappymail;
      };
      phpOptions = {
        "opcache.interned_strings_buffer" = "16";
        "output_buffering" = "0";
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
    caddy.routes = [
      {
        match = [ { host = [ config.hostnames.content ]; } ];
        handle = [
          {
            handler = "subroute";
            routes = [
              # Sets variables and headers
              {
                handle = [
                  {
                    handler = "vars";
                    # Grab the webroot out of the written config
                    # The webroot is a symlinked combined Nextcloud directory
                    root = config.services.nginx.virtualHosts.${config.services.nextcloud.hostName}.root;
                  }
                  {
                    handler = "headers";
                    response.set.Strict-Transport-Security = [ "max-age=31536000;" ];
                  }
                ];
              }
              # Reroute carddav and caldav traffic
              {
                match = [
                  {
                    path = [
                      "/.well-known/carddav"
                      "/.well-known/caldav"
                    ];
                  }
                ];
                handle = [
                  {
                    handler = "static_response";
                    headers = {
                      Location = [ "/remote.php/dav" ];
                    };
                    status_code = 301;
                  }
                ];
              }
              # Block traffic to sensitive files
              {
                match = [
                  {
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
                  }
                ];
                handle = [
                  {
                    handler = "static_response";
                    status_code = 404;
                  }
                ];
              }
              # Redirect index.php to the homepage
              {
                match = [
                  {
                    file = {
                      try_files = [ "{http.request.uri.path}/index.php" ];
                    };
                    not = [ { path = [ "*/" ]; } ];
                  }
                ];
                handle = [
                  {
                    handler = "static_response";
                    headers = {
                      Location = [ "{http.request.orig_uri.path}/" ];
                    };
                    status_code = 308;
                  }
                ];
              }
              # Rewrite paths to be relative
              {
                match = [
                  {
                    file = {
                      split_path = [ ".php" ];
                      try_files = [
                        "{http.request.uri.path}"
                        "{http.request.uri.path}/index.php"
                        "index.php"
                      ];
                    };
                  }
                ];
                handle = [
                  {
                    handler = "rewrite";
                    uri = "{http.matchers.file.relative}";
                  }
                ];
              }
              # Send all PHP traffic to Nextcloud PHP service
              {
                match = [ { path = [ "*.php" ]; } ];
                handle = [
                  {
                    handler = "reverse_proxy";
                    transport = {
                      protocol = "fastcgi";
                      split_path = [ ".php" ];
                    };
                    upstreams = [ { dial = "unix//run/phpfpm/nextcloud.sock"; } ];
                  }
                ];
              }
              # Finally, send the rest to the file server
              { handle = [ { handler = "file_server"; } ]; }
            ];
          }
        ];
        terminal = true;
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ config.hostnames.content ];

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
    systemd.services.phpfpm-nextcloud.serviceConfig.StateDirectoryMode = lib.mkForce "0770";

    # Log metrics to prometheus
    networking.hosts."127.0.0.1" = [ config.hostnames.content ];
    services.prometheus.exporters.nextcloud = {
      enable = config.prometheus.exporters.enable;
      username = config.services.nextcloud.config.adminuser;
      url = "https://${config.hostnames.content}";
      passwordFile = config.services.nextcloud.config.adminpassFile;
    };
    prometheus.scrapeTargets = [
      "127.0.0.1:${builtins.toString config.services.prometheus.exporters.nextcloud.port}"
    ];
    # Allows nextcloud-exporter to read passwordFile
    users.users.nextcloud-exporter.extraGroups =
      lib.mkIf config.services.prometheus.exporters.nextcloud.enable
        [ "nextcloud" ];
  };
}
