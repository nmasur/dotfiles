{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.git-work;
in

{

  options.nmasur.presets.programs.git-work = {
    enable = lib.mkEnableOption "Git settings for work";
    work = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Name to use for work git commits";
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Email to use for work git commits";
      };
    };
    personal = {
      name = lib.mkOption {
        type = lib.types.str;
        description = "Name to use for personal git commits";
        default = config.nmasur.presets.programs.git.name;
      };
      email = lib.mkOption {
        type = lib.types.str;
        description = "Email to use for personal git commits";
        default = config.nmasur.presets.programs.git.email;
      };
    };
  };

  config = lib.mkIf cfg.enable {

    programs.git = {
      userName = lib.mkForce cfg.work.name;
      userEmail = lib.mkForce cfg.work.email;
      includes = [
        {
          path = "${config.xdg.configHome}/${config.xdg.configFile."git/personal".target}";
          condition = "gitdir:~/dev/personal/";
        }
      ];

    };

    # Personal git config
    xdg.configFile."git/personal".text = lib.generators.toGitINI {
      user = {
        name = cfg.personal.name;
        email = cfg.personal.email;
        signingkey = "~/.ssh/id_ed25519";
      };
      commit = {
        gpgsign = true;
      };
      tag = {
        gpgsign = true;
      };
    };

  };

}
