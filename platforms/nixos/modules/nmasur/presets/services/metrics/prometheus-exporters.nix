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
  cfg = config.nmasur.presets.services.prometheus-exporters;
in
{

  options.nmasur.presets.services.prometheus-exporters = {
    enable = lib.mkEnableOption "Prometheus exporters";
    scrapeTargets = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "Prometheus scrape targets";
      default = [ ];
    };
  };

  config = lib.mkIf cfg.enable {

    # Default scrape the basic host information
    nmasur.presets.services.prometheus-exporters.scrapeTargets = [
      "127.0.0.1:${builtins.toString config.services.prometheus.exporters.node.port}"
      "127.0.0.1:${builtins.toString config.services.prometheus.exporters.systemd.port}"
      "127.0.0.1:${builtins.toString config.services.prometheus.exporters.process.port}"
    ];

    services.prometheus = {
      exporters.node.enable = config.prometheus.exporters.enable;
      exporters.node.enabledCollectors = [ ];
      exporters.node.disabledCollectors = [ "cpufreq" ];
      exporters.systemd.enable = config.prometheus.exporters.enable;
      exporters.process.enable = config.prometheus.exporters.enable;
      exporters.process.settings.process_names = [
        # Remove nix store path from process name
        {
          name = "{{.Matches.Wrapped}} {{ .Matches.Args }}";
          cmdline = [ "^/nix/store[^ ]*/(?P<Wrapped>[^ /]*) (?P<Args>.*)" ];
        }
      ];
      scrapeConfigs = [
        {
          job_name = config.networking.hostName;
          static_configs = [ { targets = cfg.scrapeTargets; } ];
        }
      ];
    };

  };
}
