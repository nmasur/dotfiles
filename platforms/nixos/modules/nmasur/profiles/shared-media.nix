{
  config,
  lib,
  ...
}:

let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.profiles.shared-media;
in

{

  options.nmasur.profiles.shared-media.enable = lib.mkEnableOption "shared media groups";

  config = lib.mkIf cfg.enable {

    # Create a shared group for many services
    users.groups.shared = { };

    # Give the human user access to the shared group
    users.users.${username}.extraGroups = [ config.users.groups.shared.name ];

    services = {
      audiobookshelf.group = "shared";
      bazarr.group = "shared";
      jellyfin.group = "shared";
      lidarr.group = "shared";
      radarr.group = "shared";
      readarr.group = "shared";
      sabnzbd.group = "shared";
      slskd.group = "shared";
      sonarr.group = "shared";
      immich.group = "shared";
      calibre-web.group = "shared";
    };

    # Fix issue where Jellyfin-created directories don't allow access for media group
    systemd.services.jellyfin.serviceConfig.UMask = lib.mkForce "0007";

  };
}
