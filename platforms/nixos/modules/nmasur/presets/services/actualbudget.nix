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
      image = "ghcr.io/actualbudget/actual-server:25.1.0";
      hostname = null;
      environmentFiles = [ ];
      environment = {
        DEBUG = "actual:config"; # Enable debug logging
        ACTUAL_TRUSTED_PROXIES = builtins.concatStringsSep "," [ "127.0.0.1" ];
      };
      dependsOn = [ ];
      autoStart = true;
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
