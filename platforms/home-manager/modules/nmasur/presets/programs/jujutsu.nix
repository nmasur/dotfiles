{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.jujutsu;
in

{

  options.nmasur.presets.programs.jujutsu.enable = lib.mkEnableOption "Jujutsu version control";

  config = lib.mkIf cfg.enable {
    programs.jujutsu = {
      enable = true;

      # https://github.com/martinvonz/jj/blob/main/docs/config.md
      settings = {
        user = {
          name = config.programs.git.settings.user.name;
          email = config.programs.git.settings.user.email;
        };
        ui.paginate = "never";

        # Automatically snapshot when files change
        fsmonitor.backend = "watchman";
        fsmonitor.watchman.register-snapshot-trigger = true;
      };
    };

    home.packages = [
      # Required for the fsmonitor to auto-snapshot
      pkgs.watchman
    ];

  };
}
