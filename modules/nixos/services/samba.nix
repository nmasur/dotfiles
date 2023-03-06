{ config, pkgs, lib, ... }: {

  options = { samba.enable = lib.mkEnableOption "Enable Samba sharing."; };

  config = {

    services.samba = lib.mkIf (config.samba.enable) {
      enable = true;
      openFirewall = true;
      shares.data = {
        path = "/data";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "force user" = config.user;
        "force group" = config.user;
        comment = "NAS";
      };
    };

    # Allows Windows clients to discover server
    services.samba-wsdd.enable = true;
    networking.firewall.allowedTCPPorts = [ 5357 ];
    networking.firewall.allowedUDPPorts = [ 3702 ];

    # Allow browsing Samba shares
    services.gvfs =
      lib.mkIf (config.gui.enable && config.nautilus.enable) { enable = true; };

    # Permissions required to mount Samba with GVFS, if not using desktop environment
    environment.systemPackages = lib.mkIf (config.gui.enable
      && config.nautilus.enable
      && config.services.xserver.windowManager.i3.enable)
      [ pkgs.lxqt.pxqt-policykit ];

  };

}
