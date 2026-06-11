{
  config,
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
      settings = {
        user = {
          name = lib.mkForce cfg.work.name;
          email = lib.mkForce cfg.work.email;
          signingKey = "~/.ssh/work_github";
        };
        commit = {
          gpgsign = true;
        };
        tag = {
          gpgsign = true;
        };
      };
      includes = [
        {
          path = "${config.home.homeDirectory}/${config.xdg.configFile."git/personal".target}";
          condition = "gitdir:~/dev/personal/";
        }
      ];

    };

    # Add work to signers file
    xdg.configFile."git/allowed-signers".text = ''
      ${cfg.work.email} ssh-ed25519 AAAAC3NzaC1lZDI1NTE5AAAAIIP7aXbmKHmWUZgwG5HPtwx+nREVeMIRplpAAzxPOFXL
    '';

    # Personal git config
    xdg.configFile."git/personal".text = lib.generators.toGitINI {
      user = {
        name = cfg.personal.name;
        email = cfg.personal.email;
        signingkey = "~/.ssh/id_ed25519";
      };
    };

    # Personal jj config
    programs.jujutsu.settings = {
      "--scope" = [
        {
          "--when".repositories = [ "~/dev/personal" ];
          user = {
            name = cfg.personal.name;
            email = cfg.personal.email;
          };
        }
      ];
    };
  };

}
