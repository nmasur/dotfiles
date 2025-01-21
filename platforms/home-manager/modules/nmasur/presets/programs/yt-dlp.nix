{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.yt-dlp;
in

{

  options.nmasur.presets.programs.yt-dlp.enable = lib.mkEnableOption "yt-dlp media downloader";

  config = lib.mkIf cfg.enable {
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
}
