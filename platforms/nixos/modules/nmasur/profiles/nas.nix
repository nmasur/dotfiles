{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.nas;
in

{

  options.nmasur.profiles.nas.enable = lib.mkEnableOption "NAS (storage device) configuration";

  config = lib.mkIf cfg.enable {

    nmasur.presets = {
      zfs.enable = lib.mkDefault true;
      programs = {
        msmtp.enable = lib.mkDefault true;
      };
      services = {
        arrs.enable = lib.mkDefault true;
        audiobookshelf.enable = lib.mkDefault true;
        bind.enable = lib.mkDefault true;
        caddy.enable = lib.mkDefault true;
        calibre-web.enable = lib.mkDefault true;
        cloudflared.enable = lib.mkDefault true;
        cloudflare.enable = lib.mkDefault true;
        filebrowser.enable = lib.mkDefault true;
        immich.enable = lib.mkDefault true;
        jellyfin.enable = lib.mkDefault true;
        litestream.enable = lib.mkDefault true;
        nextcloud.enable = lib.mkDefault true;
        nix-autoupgrade.enable = lib.mkDefault false; # Off by default for NAS
        paperless.enable = lib.mkDefault true;
        postgresql.enable = lib.mkDefault true;
        samba.enable = lib.mkDefault true;
      };
    };

  };
}
