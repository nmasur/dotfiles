{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.jujutsu;
in

{

  options.nmasur.presets.programs.jujutsu.enable = lib.mkEnableOption "Jujutsu version control";

  config = lib.mkIf cfg.enable {
    enable = true;

    # https://github.com/martinvonz/jj/blob/main/docs/config.md
    settings = {
      user = {
        name = config.programs.git.userName;
        email = config.programs.git.userEmail;
      };
    };

  };
}
