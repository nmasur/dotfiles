{ config, pkgs, lib, ... }: {

  options = { samba.enable = lib.mkEnableOption "Enable Samba sharing."; };

  config = {

    services.samba = lib.mkIf (config.samba.enable) {
      enable = true;
      openFirewall = true;
      shares.video = {
        path = "/data/video";
        browseable = "yes";
        "read only" = "no";
        "guest ok" = "no";
        "force user" = config.user;
        "force group" = config.user;
        comment = "Movies and TV";
      };
    };

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
