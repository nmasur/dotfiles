{
  config,
  pkgs,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) hostnames;
  cfg = config.nmasur.presets.services.valheim;
in

{

  options.nmasur.presets.services.valheim = {
    enable = lib.mkEnableOption "Valheim dedicated server";

    serverName = lib.mkOption {
      type = lib.types.str;
      default = "Midgard";
      description = "Server name in server browser.";
    };

    worldName = lib.mkOption {
      type = lib.types.str;
      default = "Midgard";
      description = "World save name.";
    };

    port = lib.mkOption {
      type = lib.types.port;
      default = 2456;
      description = "Server port.";
    };

    crossplay = lib.mkOption {
      type = lib.types.bool;
      default = false;
      description = "Enable cross-platform play.";
    };

    openFirewall = lib.mkOption {
      type = lib.types.bool;
      default = true;
      description = "Open UDP ports in firewall.";
    };

    passwordFile = lib.mkOption {
      type = lib.types.path;
      default = ./valheim-password.age;
      description = "Age-encrypted secret file containing the server password.";
    };
  };

  config = lib.mkIf cfg.enable {

    allowUnfreePackages = [
      "valheim-server"
      "steamworks-sdk-redist"
    ];

    secrets.valheim-password = {
      source = cfg.passwordFile;
      dest = "${config.secretsDirectory}/valheim-password";
      owner = "valheim";
      group = "valheim";
      permissions = "0400";
    };

    systemd.services.valheim-password-secret = {
      requiredBy = [ "valheim.service" ];
      before = [ "valheim.service" ];
    };

    services.valheim = {
      enable = true;
      serverName = cfg.serverName;
      worldName = cfg.worldName;
      port = cfg.port;
      crossplay = cfg.crossplay;
      openFirewall = cfg.openFirewall;
      passwordFile = config.secrets.valheim-password.dest;
    };

    # Configure Cloudflare DNS (no proxy for UDP game traffic)
    nmasur.presets.services.cloudflare.noProxyDomains = [ hostnames.valheim ];

  };

}
