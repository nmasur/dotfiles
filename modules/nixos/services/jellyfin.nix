{ config, pkgs, lib, ... }: {

  options = {
    streamServer = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Hostname for Jellyfin library";
      default = null;
    };
  };

  config = lib.mkIf (config.streamServer != null) {

    services.jellyfin.enable = true;
    users.users.jellyfin = {
      isSystemUser = true;
      group = "jellyfin";
    };

    caddy.routes = [{
      match = [{ host = [ config.streamServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:8096"; }];
      }];
    }];

    # Grant user access to Jellyfin directories
    users.users.${config.user}.extraGroups = [ "jellyfin" ];

    # Create videos directory, allow anyone in Jellyfin group to manage it
    systemd.tmpfiles.rules = [
      "d /var/lib/jellyfin 0775 jellyfin jellyfin"
      "d /var/lib/jellyfin/library 0775 jellyfin jellyfin"
    ];

    # Enable VA-API for hardware transcoding
    hardware.opengl = {
      enable = true;
      extraPackages = [ pkgs.libva ];
    };

  };

}
