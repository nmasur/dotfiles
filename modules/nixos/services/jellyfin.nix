{ config, pkgs, lib, ... }: {

  options = {
    streamServer = lib.mkOption {
      type = lib.types.nullOr lib.types.str;
      description = "Hostname for Jellyfin library";
      default = null;
    };
  };

  config = lib.mkIf config.services.jellyfin.enable {

    services.jellyfin.group = "media";
    users.users.jellyfin = { isSystemUser = true; };

    caddy.routes = [{
      match = [{ host = [ config.streamServer ]; }];
      handle = [{
        handler = "reverse_proxy";
        upstreams = [{ dial = "localhost:8096"; }];
      }];
    }];

    # Create videos directory, allow anyone in Jellyfin group to manage it
    systemd.tmpfiles.rules = [
      "d /var/lib/jellyfin 0775 jellyfin media"
      "d /var/lib/jellyfin/library 0775 jellyfin media"
    ];

    # Enable VA-API for hardware transcoding
    hardware.opengl = {
      enable = true;
      driSupport = true;
      extraPackages = [ pkgs.libva ];
    };
    environment.systemPackages = [ pkgs.libva-utils ];
    environment.variables = {
      # VAAPI and VDPAU config for accelerated video.
      # See https://wiki.archlinux.org/index.php/Hardware_video_acceleration
      "VDPAU_DRIVER" = "radeonsi";
      "LIBVA_DRIVER_NAME" = "radeonsi";
    };
    users.users.jellyfin.extraGroups =
      [ "render" "video" ]; # Access to /dev/dri

  };

}
