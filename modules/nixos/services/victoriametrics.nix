# VictoriaMetrics is a more efficient drop-in replacement for Prometheus and
# InfluxDB (timeseries databases built for monitoring system metrics).

{
  config,
  pkgs,
  lib,
  pkgs-stable,
  ...
}:

let

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

  config = {

    services.victoriametrics.extraOptions = [
      "-promscrape.config=${(pkgs.formats.yaml { }).generate "scrape.yml" prometheusConfig}"
    ];

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
      source = ../../../private/prometheus.age;
      dest = "${config.secretsDirectory}/vmauth";
      prefix = "PASSWORD=";
    };
    systemd.services.vmauth-secret = lib.mkIf config.services.victoriametrics.enable {
      requiredBy = [ "vmauth.service" ];
      before = [ "vmauth.service" ];
    };

    caddy.routes = lib.mkIf config.services.victoriametrics.enable [
      {
        match = [ { host = [ config.hostnames.prometheus ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${authPort}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains =
      if config.services.victoriametrics.enable then [ config.hostnames.prometheus ] else [ ];

    # VMAgent

    services.vmagent = {
      package = pkgs-stable.vmagent;
      prometheusConfig = prometheusConfig;
      # https://github.com/VictoriaMetrics/VictoriaMetrics/issues/5567
      extraArgs = [ "-promscrape.maxScrapeSize 450000000" ];
      remoteWrite = {
        url = "https://${config.hostnames.prometheus}/api/v1/write";
        basicAuthUsername = username;
        basicAuthPasswordFile = config.secrets.vmagent.dest;
      };
    };

    secrets.vmagent = lib.mkIf config.services.vmagent.enable {
      source = ../../../private/prometheus.age;
      dest = "${config.secretsDirectory}/vmagent";
    };
    systemd.services.vmagent-secret = lib.mkIf config.services.vmagent.enable {
      requiredBy = [ "vmagent.service" ];
      before = [ "vmagent.service" ];
    };
  };
}
