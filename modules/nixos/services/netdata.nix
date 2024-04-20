# Netdata is an out-of-the-box monitoring tool that exposes many different
# metrics. Not currently in use, in favor of VictoriaMetrics and Grafana.

{ config, lib, ... }:
{

  options.netdata.enable = lib.mkEnableOption "Netdata metrics.";

  config = lib.mkIf config.netdata.enable {

    services.netdata = {
      enable = true;

      # Disable local dashboard (unsecured)
      config = {
        web.mode = "none";
      };
    };
  };
}
