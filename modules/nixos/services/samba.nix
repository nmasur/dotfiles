# Samba is a Windows-compatible file-sharing service.

{ config, lib, ... }:
{

  config = {

    services.samba = lib.mkIf config.services.samba.enable {
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

    # Allow client browsing Samba and virtual filesystem shares
    services.gvfs = lib.mkIf (config.gui.enable && config.nautilus.enable) { enable = true; };

    # # Permissions required to mount Samba with GVFS, if not using desktop environment
    # environment.systemPackages = lib.mkIf (config.gui.enable
    #   && config.nautilus.enable
    #   && config.services.xserver.windowManager.i3.enable)
    #   [ pkgs.lxqt.lxqt-policykit ];
  };
}
