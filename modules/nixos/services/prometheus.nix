{ config, pkgs, lib, ... }: {

  options.prometheus = {
    exporters.enable = lib.mkEnableOption "Enable Prometheus exporters";
    scrapeTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Prometheus scrape targets";
      default = [ ];
    };
  };

  config = let

    # If hosting Grafana, host local Prometheus and listen for inbound jobs. If
    # not hosting Grafana, send remote Prometheus writes to primary host.
    isServer = config.services.grafana.enable;

  in {

    # Turn on exporters if any Prometheus scraper is running
    prometheus.exporters.enable = builtins.any (x: x) [
      config.services.prometheus.enable
      config.services.victoriametrics.enable
      config.services.vmagent.enable
    ];

    prometheus.scrapeTargets = [
      "127.0.0.1:${
        builtins.toString config.services.prometheus.exporters.node.port
      }"
      "127.0.0.1:${
        builtins.toString config.services.prometheus.exporters.systemd.port
      }"
      "127.0.0.1:${
        builtins.toString config.services.prometheus.exporters.process.port
      }"
    ];

    services.prometheus = {
      exporters.node.enable = config.prometheus.exporters.enable;
      exporters.systemd.enable = config.prometheus.exporters.enable;
      exporters.process.enable = config.prometheus.exporters.enable;
      exporters.process.settings.process_names = [
        # Remove nix store path from process name
        {
          name = "{{.Matches.Wrapped}} {{ .Matches.Args }}";
          cmdline = [ "^/nix/store[^ ]*/(?P<Wrapped>[^ /]*) (?P<Args>.*)" ];
        }
      ];
      extraFlags = lib.mkIf isServer [ "--web.enable-remote-write-receiver" ];
      scrapeConfigs = [{
        job_name = config.networking.hostName;
        static_configs = [{ targets = config.scrapeTargets; }];
      }];
      webExternalUrl =
        lib.mkIf isServer "https://${config.hostnames.prometheus}";
      # Web config file: https://prometheus.io/docs/prometheus/latest/configuration/https/
      webConfigFile = lib.mkIf isServer
        ((pkgs.formats.yaml { }).generate "webconfig.yml" {
          basic_auth_users = {
            # Generate password: htpasswd -nBC 10 "" | tr -d ':\n'
            # Encrypt and place in private/prometheus.age
            "prometheus" =
              "$2y$10$r7FWHLHTGPAY312PdhkPEuvb05aGn9Nk1IO7qtUUUjmaDl35l6sLa";
          };
        });
      remoteWrite = lib.mkIf (!isServer) [{
        name = config.networking.hostName;
        url = "https://${config.hostnames.prometheus}/api/v1/write";
        basic_auth = {
          # Uses password hashed with bcrypt above
          username = "prometheus";
          password_file = config.secrets.prometheus.dest;
        };
      }];
    };

    # Create credentials file for remote Prometheus push
    secrets.prometheus =
      lib.mkIf (config.services.prometheus.enable && !isServer) {
        source = ../../../private/prometheus.age;
        dest = "${config.secretsDirectory}/prometheus";
        owner = "prometheus";
        group = "prometheus";
        permissions = "0440";
      };
    systemd.services.prometheus-secret =
      lib.mkIf (config.services.prometheus.enable && !isServer) {
        requiredBy = [ "prometheus.service" ];
        before = [ "prometheus.service" ];
      };

    caddy.routes = lib.mkIf (config.services.prometheus.enable && isServer) [{
      match = [{ host = [ config.hostnames.prometheus ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams =
          [{ dial = "localhost:${config.services.prometheus.port}"; }];
      }];
    }];

  };

}
