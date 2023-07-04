{ config, pkgs, lib, ... }: {

  options.prometheusServer = lib.mkOption {
    type = lib.types.nullOr lib.types.str;
    description = "Hostname of the Prometheus server.";
    default = null;
  };

  # If hosting Grafana, host local Prometheus and listen for inbound jobs.
  # If not hosting Grafana, send remote Prometheus writes to primary host

  config = lib.mkIf config.services.prometheus.enable {

    services.prometheus = {
      exporters.node.enable = true;
      scrapeConfigs = [{
        job_name = "local";
        static_configs = [{ targets = [ "127.0.0.1:9100" ]; }];
      }];
      webExternalUrl = lib.mkIf config.services.grafana.enable
        "https://${config.prometheusServer}";
      # Web config file: https://prometheus.io/docs/prometheus/latest/configuration/https/
      webConfigFile =
        lib.mkIf config.services.grafana.enable (pkgs.formats.yaml { }).generate
        "webconfig.yml" {
          basic_auth_users = {
            # Generate password: htpasswd -nBC 10 "" | tr -d ':\n'
            # Encrypt and place in private/prometheus.age
            "prometheus" =
              "$2y$10$r7FWHLHTGPAY312PdhkPEuvb05aGn9Nk1IO7qtUUUjmaDl35l6sLa";
          };
        };
      remoteWrite = lib.mkIf (!config.services.grafana.enable) [{
        name = config.networking.hostName;
        url = "https://${config.prometheusServer}";
        basic_auth = {
          # Uses password hashed with bcrypt above
          username = "prometheus";
          password_file = config.secrets.prometheus.dest;
        };
      }];
    };

    # Create credentials file for remote Prometheus push
    secrets.prometheus = lib.mkIf (!config.services.grafana.enable) {
      source = ../../../private/prometheus.age;
      dest = "${config.secretsDirectory}/prometheus";
      owner = "prometheus";
      group = "prometheus";
      permissions = "0440";
    };
    systemd.services.prometheus-secret =
      lib.mkIf (!config.services.grafana.enable) {
        requiredBy = [ "prometheus.service" ];
        before = [ "prometheus.service" ];
      };

    caddy.routes = lib.mkIf config.services.grafana.enable [{
      match = [{ host = [ config.prometheusServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:9090"; }];
      }];
    }];

  };

}
