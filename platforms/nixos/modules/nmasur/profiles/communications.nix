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
        caddy.enable = lib.mkDefault true;
        cloudflare.enable = lib.mkDefault true;
        cloudflared.enable = lib.mkDefault true;
        gitea.enable = lib.mkDefault true;
        grafana.enable = lib.mkDefault true;
        influxdb2.enable = lib.mkDefault true;
        litestream.enable = lib.mkDefault true;
        minecraft-server.enable = lib.mkDefault true;
        n8n.enable = lib.mkDefault true;
        nix-autoupgrade.enable = lib.mkDefault false; # On by default for communications
        ntfy-sh.enable = lib.mkDefault true;
        postgresql.enable = lib.mkDefault true;
        thelounge.enable = lib.mkDefault true;
        uptime-kuma.enable = lib.mkDefault true;
        vaultwarden.enable = lib.mkDefault true;
        victoriametrics.enable = lib.mkDefault true;
      };
    };

  };
}
