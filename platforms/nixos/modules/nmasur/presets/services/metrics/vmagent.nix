# VictoriaMetrics is a more efficient drop-in replacement for Prometheus and
# InfluxDB (timeseries databases built for monitoring system metrics).

{
  config,
  pkgs,
  lib,
  ...
}:

let

  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.vmagent;

  username = "prometheus";

  prometheusConfig = {
    scrape_configs = [
      {
        job_name = config.networking.hostName;
        stream_parse = true;
        static_configs = [
          { targets = config.nmasur.presets.services.prometheus-exporters.scrapeTargets; }
        ];
      }
    ];
  };

in
{

  options.nmasur.presets.services.vmagent.enable =
    lib.mkEnableOption "vmagent VictoriaMetrics collector";

  config = lib.mkIf cfg.enable {

    services.vmagent = {
      enable = true;
      package = pkgs.stable.vmagent;
      prometheusConfig = prometheusConfig;
      remoteWrite = {
        url = "https://${hostnames.prometheus}/api/v1/write";
        basicAuthUsername = username;
        basicAuthPasswordFile = config.secrets.vmagent.dest;
      };
    };

    secrets.vmagent = {
      source = ./prometheus.age;
      dest = "${config.secretsDirectory}/vmagent";
    };
    systemd.services.vmagent-secret = lib.mkIf config.services.vmagent.enable {
      requiredBy = [ "vmagent.service" ];
      before = [ "vmagent.service" ];
    };
  };
}
