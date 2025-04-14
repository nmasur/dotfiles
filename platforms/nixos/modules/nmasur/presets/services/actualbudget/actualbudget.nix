{
  config,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.actualbudget;
in

{

  options.nmasur.presets.services.actualbudget = {
    enable = lib.mkEnableOption "ActualBudget budgeting service";
    port = lib.mkOption {
      type = lib.types.port;
      description = "Port to use for the localhost";
      default = 5006;
    };
  };

  config = lib.mkIf cfg.enable {

    services.actual = {
      enable = true;
      settings = {
        port = 5006;
      };
    };

    # Used for prometheus exporter
    virtualisation.podman.enable = true;

    # Create a shared group for generic services
    users.groups.shared = { };

    users.users.actualbudget = {
      isSystemUser = true;
      group = "shared";
      uid = 980;
    };

    virtualisation.oci-containers.containers.actualbudget-prometheus-exporter = {
      workdir = null;
      user = builtins.toString config.users.users.actualbudget.uid;
      pull = "missing";
      privileged = false;
      ports = [ "127.0.0.1:5007:3001" ];
      networks = [ ];
      log-driver = "journald";
      labels = {
        app = "actualbudget-prometheus-exporter";
      };
      image = "docker.io/sakowicz/actual-budget-prometheus-exporter:1.1.5";
      hostname = null;
      environmentFiles = [
        config.secrets.actualbudget-password.dest
        config.secrets.actualbudget-budget-id.dest
      ];
      environment = {
        ACTUAL_SERVER_URL = "https://${hostnames.budget}:443";
      };
      # dependsOn = [ "actualbudget" ];
      autoStart = true;
    };

    nmasur.presets.services.prometheus-exporters.scrapeTargets = [
      "127.0.0.1:5007"
    ];

    secrets.actualbudget-password = {
      source = ./actualbudget-password.age;
      dest = "${config.secretsDirectory}/actualbudget-password";
      owner = builtins.toString config.users.users.actualbudget.uid;
      group = builtins.toString config.users.users.actualbudget.uid;
    };
    secrets.actualbudget-budget-id = {
      source = ./actualbudget-budget-id.age;
      dest = "${config.secretsDirectory}/actualbudget-budget-id";
      owner = builtins.toString config.users.users.actualbudget.uid;
      group = builtins.toString config.users.users.actualbudget.uid;
    };

    # Allow web traffic to Caddy
    nmasur.presets.services.caddy.routes = [
      {
        match = [ { host = [ hostnames.budget ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString cfg.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ hostnames.budget ];

    # Backups
    services.restic.backups.default.paths = [ "/var/lib/actualbudget" ];

  };

}
