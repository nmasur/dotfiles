# InfluxDB is a timeseries database similar to Prometheus. While
# VictoriaMetrics can also act as an InfluxDB, this version of it allows for
# infinite retention separate from our other metrics, which can be nice for
# recording health information, for example.

{ config, lib, ... }:
{

  config = lib.mkIf config.services.influxdb2.enable {

    services.influxdb2 = {
      provision = {
        enable = true;
        initialSetup = {
          bucket = "default";
          organization = "main";
          passwordFile = config.secrets.influxdb2Password.dest;
          retention = 0; # Keep data forever
          tokenFile = config.secrets.influxdb2Token.dest;
          username = "admin";
        };
      };
      settings = { };
    };

    # Create credentials file for InfluxDB admin
    secrets.influxdb2Password = lib.mkIf config.services.influxdb2.enable {
      source = ../../../private/influxdb2-password.age;
      dest = "${config.secretsDirectory}/influxdb2-password";
      owner = "influxdb2";
      group = "influxdb2";
      permissions = "0440";
    };
    systemd.services.influxdb2Password-secret = lib.mkIf config.services.influxdb2.enable {
      requiredBy = [ "influxdb2.service" ];
      before = [ "influxdb2.service" ];
    };
    secrets.influxdb2Token = lib.mkIf config.services.influxdb2.enable {
      source = ../../../private/influxdb2-token.age;
      dest = "${config.secretsDirectory}/influxdb2-token";
      owner = "influxdb2";
      group = "influxdb2";
      permissions = "0440";
    };
    systemd.services.influxdb2Token-secret = lib.mkIf config.services.influxdb2.enable {
      requiredBy = [ "influxdb2.service" ];
      before = [ "influxdb2.service" ];
    };

    caddy.routes = lib.mkIf config.services.influxdb2.enable [
      {
        match = [ { host = [ config.hostnames.influxdb ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:8086"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ config.hostnames.influxdb ];
  };
}
