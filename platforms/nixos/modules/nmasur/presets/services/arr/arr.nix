{
  config,
  pkgs,
  lib,
  ...
}:

let

  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.arrs;

  # This config specifies ports for Prometheus to scrape information
  arrConfig = {
    radarr = {
      exportarrPort = "9707";
      url = "localhost:7878";
      apiKey = config.secrets.radarrApiKey.dest;
    };
    readarr = {
      exportarrPort = "9711";
      url = "localhost:8787";
      apiKey = config.secrets.readarrApiKey.dest;
    };
    sonarr = {
      exportarrPort = "9708";
      url = "localhost:8989";
      apiKey = config.secrets.sonarrApiKey.dest;
    };
    lidarr = {
      exportarrPort = "9712";
      url = "localhost:8686";
      apiKey = config.secrets.lidarrApiKey.dest;
    };
    prowlarr = {
      exportarrPort = "9709";
      url = "localhost:9696";
      apiKey = config.secrets.prowlarrApiKey.dest;
    };
    sabnzbd = {
      exportarrPort = "9710";
      url = "localhost:8085";
      apiKey = config.secrets.sabnzbdApiKey.dest;
    };
  };
in
{

  options.nmasur.presets.services.arrs.enable = lib.mkEnableOption "Arr services";

  config = lib.mkIf cfg.enable {

    # Required
    nmasur.profiles.shared-media.enable = true; # Shared user for multiple services

    # # Broken on 2024-12-07
    # # https://discourse.nixos.org/t/solved-sonarr-is-broken-in-24-11-unstable-aka-how-the-hell-do-i-use-nixpkgs-config-permittedinsecurepackages/
    # insecurePackages = [
    #   "aspnetcore-runtime-wrapped-6.0.36"
    #   "aspnetcore-runtime-6.0.36"
    #   "dotnet-sdk-wrapped-6.0.428"
    #   "dotnet-sdk-6.0.428"
    # ];

    secrets.slskd = {
      source = ./slskd.age;
      dest = "/var/private/slskd";
    };

    services = {
      bazarr = {
        enable = true;
      };
      jellyseerr.enable = true;
      prowlarr.enable = true;
      sabnzbd = {
        enable = true;
        # The config file must be editable within the application
        # It contains server configs and credentials
        configFile = "/data/downloads/sabnzbd/sabnzbd.ini";
      };
      slskd = {
        enable = true;
        domain = null;
        environmentFile = config.secrets.slskd.dest;
        settings = {
          shares.directories = [ ];
          directories.downloads = "/data/audio/music";
          web = {
            url_base = "/slskd";
            port = 5030;
          };
          soulseek.listen_port = 50300;
        };
        openFirewall = false;
      };
      sonarr = {
        enable = true;
      };
      radarr = {
        enable = true;
      };
      readarr = {
        enable = true;
      };
      lidarr = {
        enable = true;
      };
    };

    # Allows shared group to read/write the sabnzbd directory
    users.users.sabnzbd.homeMode = "0770";

    allowUnfreePackages = [ "unrar" ]; # Required as a dependency for sabnzbd

    # Requires updating the base_url config value in each service
    # If you try to rewrite the URL, the service won't redirect properly
    nmasur.presets.services.caddy.routes = [
      {
        # Group means that routes with the same name are mutually exclusive,
        # so they are split between the appropriate services.
        match = [
          {
            host = [ hostnames.download ];
            path = [ "/sonarr*" ];
          }
        ];
        handle = [
          {
            handler = "reverse_proxy";
            # We're able to reference the url and port of the service dynamically
            upstreams = [ { dial = arrConfig.sonarr.url; } ];
          }
        ];
      }
      {
        match = [
          {
            host = [ hostnames.download ];
            path = [ "/radarr*" ];
          }
        ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = arrConfig.radarr.url; } ];
          }
        ];
      }
      {
        match = [
          {
            host = [ hostnames.download ];
            path = [ "/readarr*" ];
          }
        ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = arrConfig.readarr.url; } ];
          }
        ];
      }
      {
        match = [
          {
            host = [ hostnames.download ];
            path = [ "/lidarr*" ];
          }
        ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = arrConfig.lidarr.url; } ];
          }
        ];
      }
      {
        match = [
          {
            host = [ hostnames.download ];
            path = [ "/prowlarr*" ];
          }
        ];
        handle = [
          {
            handler = "reverse_proxy";
            # Prowlarr doesn't offer a dynamic config, so we have to hardcode it
            upstreams = [ { dial = "localhost:9696"; } ];
          }
        ];
      }
      {
        match = [
          {
            host = [ hostnames.download ];
            path = [ "/bazarr*" ];
          }
        ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              {
                # Bazarr only dynamically sets the port, not the host
                dial = "localhost:${builtins.toString config.services.bazarr.listenPort}";
              }
            ];
          }
        ];
      }
      {
        match = [
          {
            host = [ hostnames.download ];
            path = [ "/sabnzbd*" ];
          }
        ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = arrConfig.sabnzbd.url; } ];
          }
        ];
      }
      {
        match = [
          {
            host = [ hostnames.download ];
            path = [ "/slskd*" ];
          }
        ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [
              { dial = "localhost:${builtins.toString config.services.slskd.settings.web.port}"; }
            ];
          }
        ];
      }
      {
        match = [ { host = [ hostnames.download ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.jellyseerr.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.download ];

    # Enable Prometheus exporters
    systemd.services = lib.mapAttrs' (name: attrs: {
      name = "prometheus-${name}-exporter";
      value = {
        description = "Export Prometheus metrics for ${name}";
        after = [ "network.target" ];
        wantedBy = [ "${name}.service" ];
        serviceConfig = {
          Type = "simple";
          DynamicUser = true;
          ExecStart =
            let
              # Sabnzbd doesn't accept the URI path, unlike the others
              url = if name != "sabnzbd" then "http://${attrs.url}/${name}" else "http://${attrs.url}";
            in
            # Exportarr is trained to pull from the arr services
            ''
              ${pkgs.exportarr}/bin/exportarr ${name} \
                          --url ${url} \
                          --port ${attrs.exportarrPort}'';
          EnvironmentFile = lib.mkIf (builtins.hasAttr "apiKey" attrs) attrs.apiKey;
          Restart = "on-failure";
          ProtectHome = true;
          ProtectSystem = "strict";
          PrivateTmp = true;
          PrivateDevices = true;
          ProtectHostname = true;
          ProtectClock = true;
          ProtectKernelTunables = true;
          ProtectKernelModules = true;
          ProtectKernelLogs = true;
          ProtectControlGroups = true;
          NoNewPrivileges = true;
          RestrictRealtime = true;
          RestrictSUIDSGID = true;
          RemoveIPC = true;
          PrivateMounts = true;
        };
      };
    }) arrConfig;

    # Secrets for Prometheus exporters
    secrets.radarrApiKey = {
      source = ./radarr-api-key.age;
      dest = "/var/private/radarr-api";
      prefix = "API_KEY=";
    };
    secrets.readarrApiKey = {
      source = ./readarr-api-key.age;
      dest = "/var/private/readarr-api";
      prefix = "API_KEY=";
    };
    secrets.sonarrApiKey = {
      source = ./sonarr-api-key.age;
      dest = "/var/private/sonarr-api";
      prefix = "API_KEY=";
    };
    secrets.lidarrApiKey = {
      source = ./lidarr-api-key.age;
      dest = "/var/private/lidarr-api";
      prefix = "API_KEY=";
    };
    secrets.prowlarrApiKey = {
      source = ./prowlarr-api-key.age;
      dest = "/var/private/prowlarr-api";
      prefix = "API_KEY=";
    };
    secrets.sabnzbdApiKey = {
      source = ./sabnzbd-api-key.age;
      dest = "/var/private/sabnzbd-api";
      prefix = "API_KEY=";
    };

    # Prometheus scrape targets (expose Exportarr to Prometheus)
    nmasur.presets.services.prometheus-exporters.scrapeTargets = map (
      key:
      "127.0.0.1:${
        lib.attrsets.getAttrFromPath [
          key
          "exportarrPort"
        ] arrConfig
      }"
    ) (builtins.attrNames arrConfig);
  };
}
