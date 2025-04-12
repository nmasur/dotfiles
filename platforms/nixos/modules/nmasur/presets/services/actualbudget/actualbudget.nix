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

    virtualisation.podman.enable = true;

    # Create a shared group for generic services
    users.groups.shared = { };

    users.users.actualbudget = {
      isSystemUser = true;
      group = "shared";
      uid = 980;
    };

    # Create budget directory, allowing others to manage it
    systemd.tmpfiles.rules = [
      "d /var/lib/actualbudget 0770 actualbudget shared"
    ];

    # TODO: switch to NixOS service
    virtualisation.oci-containers.containers.actualbudget = {
      workdir = null;
      volumes = [ "/var/lib/actualbudget:/data" ];
      user = "${toString (builtins.toString config.users.users.actualbudget.uid)}";
      pull = "missing";
      privileged = false;
      ports = [ "127.0.0.1:${builtins.toString cfg.port}:5006" ];
      networks = [ ];
      log-driver = "journald";
      labels = {
        app = "actualbudget";
      };
      image = "ghcr.io/actualbudget/actual:25.3.1";
      hostname = null;
      environmentFiles = [ ];
      environment = {
        DEBUG = "actual:config"; # Enable debug logging
        ACTUAL_TRUSTED_PROXIES = builtins.concatStringsSep "," [ "127.0.0.1" ];
      };
      dependsOn = [ ];
      autoStart = true;
    };

    virtualisation.oci-containers.containers.actualbudget-prometheus-exporter = {
      workdir = null;
      user = builtins.toString config.users.users.actualbudget.uid;
      pull = "missing";
      privileged = false;
      ports = [ "127.0.0.1:${builtins.toString cfg.port}:5007" ];
      networks = [ ];
      log-driver = "journald";
      labels = {
        app = "actualbudget-prometheus-exporter";
      };
      image = "docker.io/sakowicz/actual-budget-prometheus-exporter:1.1.6";
      hostname = null;
      environmentFiles = [ config.secrets.actualbudget.dest ];
      environment = {
        ACTUAL_SERVER_URL = "http://127.0.0.1:5006";
        ACTUAL_BUDGET_ID_1 = "My-Finances-1daef08";
      };
      dependsOn = [ "actualbudget" ];
      autoStart = true;
    };

    secrets.actualbudget = {
      source = ./actualbudget-password.age;
      dest = "${config.secretsDirectory}/actualbudget-password";
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
