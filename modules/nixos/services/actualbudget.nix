{ config, lib, ... }:
{

  options = {
    services.actualbudget = {
      enable = lib.mkEnableOption "ActualBudget budgeting service";
      port = lib.mkOption {
        type = lib.types.port;
        description = "Port to use for the localhost";
        default = 5006;
      };
    };
  };

  config = lib.mkIf config.services.actualbudget.enable {

    virtualisation.podman.enable = lib.mkDefault true;

    users.users.actualbudget = {
      isSystemUser = true;
      group = "shared";
      uid = 980;
    };

    # Create budget directory, allowing others to manage it
    systemd.tmpfiles.rules = [
      "d /var/lib/actualbudget 0770 actualbudget shared"
    ];

    virtualisation.oci-containers.containers.actualbudget = {
      workdir = null;
      volumes = [ "/var/lib/actualbudget:/data" ];
      user = "${toString (builtins.toString config.users.users.actualbudget.uid)}";
      pull = "missing";
      privileged = false;
      ports = [ "127.0.0.1:${builtins.toString config.services.actualbudget.port}:5006" ];
      networks = [ ];
      log-driver = "journald";
      labels = {
        app = "actualbudget";
      };
      image = "ghcr.io/actualbudget/actual-server:latest";
      hostname = null;
      environmentFiles = [ ];
      environment = { };
      dependsOn = [ ];
      autoStart = true;
    };

    # Allow web traffic to Caddy
    caddy.routes = [
      {
        match = [ { host = [ config.hostnames.budget ]; } ];
        handle = [
          {
            handler = "reverse_proxy";
            upstreams = [ { dial = "localhost:${builtins.toString config.services.actualbudget.port}"; } ];
          }
        ];
      }
    ];

    # Configure Cloudflare DNS to point to this machine
    services.cloudflare-dyndns.domains = [ config.hostnames.budget ];

  };

}
