# VictoriaMetrics is a more efficient drop-in replacement for Prometheus and
# InfluxDB (timeseries databases built for monitoring system metrics).

{
  config,
  lib,
  pkgs-stable,
  ...
}:

let

  cfg = config.nmasur.presets.services.vm-agent;
  hostnames = config.nmasur.settings.hostnames;

  username = "prometheus";

  prometheusConfig = {
    scrape_configs = [
      {
        job_name = config.networking.hostName;
        stream_parse = true;
        static_configs = [ { targets = config.prometheus.scrapeTargets; } ];
      }
    ];
  };

in
{

  options.nmasur.presets.services.vm-agent.enable =
    lib.mkEnableOption "vm-agent VictoriaMetrics collector";

  config = lib.mkIf cfg.enable {

    services.vmagent = {
      enable = true;
      package = pkgs-stable.vmagent;
      prometheusConfig = prometheusConfig;
      remoteWrite = {
        url = "https://${hostnames.prometheus}/api/v1/write";
        basicAuthUsername = username;
        basicAuthPasswordFile = config.secrets.vmagent.dest;
      };
    };

    secrets.vmagent = {
      source = ../../../private/prometheus.age;
      dest = "${config.secretsDirectory}/vmagent";
    };
    systemd.services.vmagent-secret = lib.mkIf config.services.vmagent.enable {
      requiredBy = [ "vmagent.service" ];
      before = [ "vmagent.service" ];
    };
  };
}
