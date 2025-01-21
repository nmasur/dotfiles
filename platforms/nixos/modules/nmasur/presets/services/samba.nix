# Samba is a Windows-compatible file-sharing service.

{ config, lib, ... }:

let
  cfg = config.nmasur.presets.services.samba;
in
{

  options.nmasur.presets.services.samba.enable = lib.mkEnableOption "Samba network filesharing";

  config = {

    services.samba = lib.mkIf cfg.enable {
      enable = true;
      openFirewall = true;
      settings.data = {
        path = "/data";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        comment = "NAS";
      };
    };

    # Allows Windows clients to discover server
    services.samba-wsdd.enable = true;
    networking.firewall.allowedTCPPorts = [ 5357 ];
    networking.firewall.allowedUDPPorts = [ 3702 ];
  };
}
