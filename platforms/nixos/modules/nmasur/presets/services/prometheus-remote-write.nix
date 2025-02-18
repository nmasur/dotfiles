# Prometheus is a timeseries database that exposes system and service metrics
# for use in visualizing, monitoring, and alerting (with Grafana).

# Instead of running traditional Prometheus, I generally run VictoriaMetrics as
# a more efficient drop-in replacement.

{
  config,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.prometheus-remote-write;
in
{

  options.nmasur.presets.services.prometheus-remote-write = {
    enable = lib.mkEnableOption "Prometheus remote write for agent machines";
  };

  config = lib.mkIf cfg.enable {

    services.prometheus = {
      remoteWrite = [
        {
          name = config.networking.hostName;
          url = "https://${hostnames.prometheus}/api/v1/write";
          basic_auth = {
            # Uses password hashed with bcrypt above
            username = "prometheus";
            password_file = config.secrets.prometheus.dest;
          };
        }
      ];
    };

    # Create credentials file for remote Prometheus push
    secrets.prometheus = {
      source = ../../../../../../private/prometheus.age;
      dest = "${config.secretsDirectory}/prometheus";
      owner = "prometheus";
      group = "prometheus";
      permissions = "0440";
    };
    systemd.services.prometheus-secret = {
      requiredBy = [ "prometheus.service" ];
      before = [ "prometheus.service" ];
    };
  };
}
