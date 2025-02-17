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

    services = {
      bazarr = {
        enable = true;
        group = lib.mkIf config.nmasur.profiles.shared-media.enable "shared";
      };
      jellyseerr.enable = true;
      prowlarr.enable = true;
      sabnzbd = {
        enable = true;
        group = lib.mkIf config.nmasur.profiles.shared-media.enable "shared";
        # The config file must be editable within the application
        # It contains server configs and credentials
        configFile = "/data/downloads/sabnzbd/sabnzbd.ini";
      };
      sonarr = {
        enable = true;
        group = lib.mkIf config.nmasur.profiles.shared-media.enable "shared";
      };
      radarr = {
        enable = true;
        group = lib.mkIf config.nmasur.profiles.shared-media.enable "shared";
      };
      readarr = {
        enable = true;
        group = lib.mkIf config.nmasur.profiles.shared-media.enable "shared";
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
        group = "download";
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
        group = "download";
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
        group = "download";
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
        group = "download";
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
        group = "download";
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
        group = "download";
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
        group = "download";
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
      source = ../../../private/radarr-api-key.age;
      dest = "/var/private/radarr-api";
      prefix = "API_KEY=";
    };
    secrets.readarrApiKey = {
      source = ../../../private/radarr-api-key.age;
      dest = "/var/private/readarr-api";
      prefix = "API_KEY=";
    };
    secrets.sonarrApiKey = {
      source = ../../../private/sonarr-api-key.age;
      dest = "/var/private/sonarr-api";
      prefix = "API_KEY=";
    };
    secrets.prowlarrApiKey = {
      source = ../../../private/prowlarr-api-key.age;
      dest = "/var/private/prowlarr-api";
      prefix = "API_KEY=";
    };
    secrets.sabnzbdApiKey = {
      source = ../../../private/sabnzbd-api-key.age;
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
