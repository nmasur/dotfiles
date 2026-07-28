{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.communications;
in

{

  options.nmasur.profiles.communications.enable =
    lib.mkEnableOption "communications server configuration";

  config = lib.mkIf cfg.enable {

    nmasur.presets = {
      programs = {
        msmtp.enable = lib.mkDefault true;
      };
      services = {
        actualbudget.enable = lib.mkDefault true;
        actualtap = {
          enable = lib.mkDefault true;
          instances = {
            budget1 = {
              port = 3031;
              path = "/actualtap1";
              budgetIdFile = ../presets/services/actualtap/budget1-id.age;
              apiKeyFile = ../presets/services/actualtap/budget1-api-key.age;
            };
            budget2 = {
              port = 3032;
              path = "/actualtap2";
              budgetIdFile = ../presets/services/actualtap/budget2-id.age;
              apiKeyFile = ../presets/services/actualtap/budget2-api-key.age;
            };
          };
        };
        caddy.enable = lib.mkDefault true;
        cloudflare.enable = lib.mkDefault true;
        cloudflared.enable = lib.mkDefault true;
        gitea.enable = lib.mkDefault true;
        grafana.enable = lib.mkDefault true;
        influxdb2.enable = lib.mkDefault true;
        karakeep.enable = lib.mkDefault true;
        litestream.enable = lib.mkDefault true;
        mathesar.enable = lib.mkDefault true;
        mealie.enable = lib.mkDefault true;
        minecraft-server.enable = lib.mkDefault false;
        murmur.enable = lib.mkDefault false;
        n8n.enable = lib.mkDefault true;
        nix-autoupgrade.enable = lib.mkDefault true; # On by default for communications
        ntfy-sh.enable = lib.mkDefault true;
        pgweb.enable = lib.mkDefault true;
        postgresql.enable = lib.mkDefault true;
        stalwart.enable = lib.mkDefault true;
        thelounge.enable = lib.mkDefault true;
        uptime-kuma.enable = lib.mkDefault true;
        vaultwarden.enable = lib.mkDefault true;
        victoriametrics.enable = lib.mkDefault true;
      };
    };

  };
}
