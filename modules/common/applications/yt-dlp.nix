{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    yt-dlp = {
      enable = lib.mkEnableOption {
        description = "Enable YouTube downloader.";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.yt-dlp.enable) {
    home-manager.users.${config.user} = {
      programs.yt-dlp = {
        enable = true;
        extraConfig = "";
        settings = {
          no-continue = true; # Always re-download each fragment
          no-overwrites = true; # Don't overwrite existing files
          download-archive = "archive.log"; # Log of archives
          embed-metadata = true;
          embed-thumbnail = true;
          embed-subs = true;
          sub-langs = "en.*";
          concurrent-fragments = 4; # Parallel download chunks
        };
      };

      programs.fish.shellAbbrs.yt = "yt-dlp";
    };
  };
}
