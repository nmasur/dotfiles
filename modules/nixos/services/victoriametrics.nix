{ config, pkgs, lib, ... }:

let

  username = "prometheus";

  prometheusConfig = (pkgs.formats.yaml { }).generate "prometheus.yml" {
    scrape_configs = [{
      job_name = config.networking.hostName;
      stream_parse = true;
      static_configs = [{ targets = config.prometheus.scrapeTargets; }];
    }];
  };

  authConfig = (pkgs.formats.yaml { }).generate "auth.yml" {
    users = [{
      username = username;
      password = "%{PASSWORD}";
      url_prefix =
        "http://localhost${config.services.victoriametrics.listenAddress}";
    }];
  };

  authPort = "8427";

in {

  config = {

    services.victoriametrics.extraOptions =
      [ "-promscrape.config=${prometheusConfig}" ];

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
    systemd.services.vmauth-secret =
      lib.mkIf config.services.victoriametrics.enable {
        requiredBy = [ "vmauth.service" ];
        before = [ "vmauth.service" ];
      };

    caddy.routes = lib.mkIf config.services.victoriametrics.enable [{
      match = [{ host = [ config.hostnames.prometheus ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:${authPort}"; }];
      }];
    }];

    # VMAgent

    services.vmagent.prometheusConfig = prometheusConfig; # Overwritten below
    systemd.services.vmagent.serviceConfig =
      lib.mkIf config.services.vmagent.enable {
        ExecStart = lib.mkForce ''
          ${pkgs.victoriametrics}/bin/vmagent \
                  -promscrape.config=${prometheusConfig} \
                  -remoteWrite.url="https://${config.hostnames.prometheus}/api/v1/write" \
                  -remoteWrite.basicAuth.username=${username} \
                  -remoteWrite.basicAuth.passwordFile=${config.secrets.vmagent.dest}'';
      };

    secrets.vmagent = lib.mkIf config.services.vmagent.enable {
      source = ../../../private/prometheus.age;
      dest = "${config.secretsDirectory}/vmagent";
      owner = "vmagent";
      group = "vmagent";
    };
    systemd.services.vmagent-secret = lib.mkIf config.services.vmagent.enable {
      requiredBy = [ "vmagent.service" ];
      before = [ "vmagent.service" ];
    };

  };

}
