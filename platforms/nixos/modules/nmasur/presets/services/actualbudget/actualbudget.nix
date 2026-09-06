{
  config,
  pkgs,
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
    prometheusPort = lib.mkOption {
      type = lib.types.port;
      description = "Port to use for prometheus actual exporter";
      default = 5007;
    };
  };

  config = lib.mkIf cfg.enable {

    services.actual = {
      enable = true;
      settings = {
        port = cfg.port;
        loginMethod = "openid";
        openId = {
          discoveryURL = "https://${hostnames.auth}/.well-known/openid-configuration";
          client_id = "92afe9f8-7ef6-42ab-8a06-701df3c7179d";
          client_secret._secret = config.secrets.actualbudget-oidc-secret.dest;
          server_hostname = "https://${hostnames.budget}";
          authMethod = "openid";
        };
      };
    };

    systemd.services.actual = {
      after = [ "actualbudget-oidc-secret-secret.service" ];
      serviceConfig = {
        PrivateUsers = lib.mkForce false;
        SupplementaryGroups = [ "shared" ];
      };
    };

    # systemd.services.prometheus-actual-exporter = {
    #   enable = true;
    #   description = "Prometheus exporter for Actual budget";
    #   serviceConfig = {
    #     DynamicUser = true;
    #     Environment = [
    #       "ACTUAL_SERVER_URL=https://${hostnames.budget}:443"
    #       "PORT=${builtins.toString cfg.prometheusPort}"
    #     ];
    #     EnvironmentFile = [
    #       config.secrets.actualbudget-password.dest
    #       config.secrets.actualbudget-budget-id.dest
    #     ];
    #     ExecStart = lib.getExe pkgs.nmasur.prometheus-actual-exporter;
    #   };
    #   wantedBy = [
    #     "multi-user.target"
    #   ];
    # };

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
      "127.0.0.1:${builtins.toString cfg.prometheusPort}"
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
    secrets.actualbudget-oidc-secret = {
      source = ./actualbudget-oidc-secret.age;
      dest = "${config.secretsDirectory}/actualbudget-oidc-secret";
      owner = config.users.users.actualbudget.name;
      group = config.users.groups.shared.name;
      permissions = "0440";
    };
    systemd.services.actualbudget-oidc-secret-secret = {
      requiredBy = [ "actual.service" ];
      before = [ "actual.service" ];
    };

    # Allow web traffic to Caddy
    nmasur.presets.services.caddy.routes = lib.mkAfter [
      {
        group = "actual";
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
    services.restic.backups.default.paths = [ "/var/lib/private/actual" ];

  };

}
