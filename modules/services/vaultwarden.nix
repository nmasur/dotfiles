{ config, lib, ... }: {

  options = {

    vaultwardenServer = lib.mkOption {
      description = "Hostname for Vaultwarden.";
      type = lib.types.str;
    };

  };

  config = {
    services.vaultwarden = {
      enable = true;
      config = {
        DOMAIN = "https://${config.vaultwardenServer}";
        SIGNUPS_ALLOWED = false;
        SIGNUPS_VERIFY = true;
        INVITATIONS_ALLOWED = true;
        WEB_VAULT_ENABLED = true;
        ROCKET_ADDRESS = "127.0.0.1";
        ROCKET_PORT = 8222;
        WEBSOCKET_ENABLED = true;
        WEBSOCKET_ADDRESS = "0.0.0.0";
        WEBSOCKET_PORT = 3012;
        LOGIN_RATELIMIT_SECONDS = 60;
        LOGIN_RATELIMIT_MAX_BURST = 10;
        ADMIN_RATELIMIT_SECONDS = 300;
        ADMIN_RATELIMIT_MAX_BURST = 3;
      };
      environmentFile = config.secrets.vaultwarden.dest;
      dbBackend = "sqlite";
    };

    secrets.vaultwarden = {
      source = ../../private/vaultwarden.age;
      dest = "${config.secretsDirectory}/vaultwarden";
      owner = "vaultwarden";
      group = "vaultwarden";
    };

    networking.firewall.allowedTCPPorts = [ 3012 ];

    caddyRoutes = [{
      match = [{ host = [ config.vaultwardenServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:8222"; }];
      }];
    }];

}
