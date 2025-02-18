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
  cfg = config.nmasur.presets.services.victoriametrics;

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

  authConfig = (pkgs.formats.yaml { }).generate "auth.yml" {
    users = [
      {
        username = username;
        password = "%{PASSWORD}";
        url_prefix = "http://localhost${config.services.victoriametrics.listenAddress}";
      }
    ];
  };

  authPort = "8427";
in
{

  options.nmasur.presets.services.victoriametrics.enable =
    lib.mkEnableOption "VictoriaMetrics timeseries database";

  config = lib.mkIf cfg.enable {

    services.victoriametrics = {
      enable = true;
      extraOptions = [
        "-promscrape.config=${(pkgs.formats.yaml { }).generate "scrape.yml" prometheusConfig}"
      ];
    };

    systemd.services.vmauth = lib.mkIf config.services.victoriametrics.enable {
      description = "VictoriaMetrics basic auth proxy";
      after = [ "network.target" ];
      startLimitBurst = 5;
      serviceConfig = {
        Restart = "on-failure";
        RestartSec = 1;
        DynamicUser = true;
        EnvironmentFile = config.secrets.vmauth.dest;
        ExecStart = ''
          ${pkgs.victoriametrics}/bin/vmauth \
                    -auth.config=${authConfig} \
                    -httpListenAddr=:${authPort}'';
      };
      wantedBy = [ "multi-user.target" ];
    };

    secrets.vmauth = lib.mkIf config.services.victoriametrics.enable {
      source = ../../../../../../private/prometheus.age;
      dest = "${config.secretsDirectory}/vmauth";
      prefix = "PASSWORD=";
    };
    systemd.services.vmauth-secret = lib.mkIf config.services.victoriametrics.enable {
      requiredBy = [ "vmauth.service" ];
      before = [ "vmauth.service" ];
    };

    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.prometheus ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${authPort}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.prometheus ];

  };
}
