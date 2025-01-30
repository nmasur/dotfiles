{ config, lib, ... }:

let
  cfg = config.nmasur.presets.programs.wine;
in

{
  options.nmasur.presets.programs.wine.enable = lib.mkEnableOption "Wine settings";

  config = lib.mkIf cfg.enable {

    # Ignore wine directories in searches
    home.file =
      let
        ignorePatterns = ''
          .wine/
          drive_c/'';
      in
      {
        ".rgignore".text = ignorePatterns;
        ".fdignore".text = ignorePatterns;
      };

  };
}
