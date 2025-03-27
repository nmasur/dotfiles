{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.dotfiles;
in
{

  # Allows me to make sure I can work on my dotfiles locally

  options.nmasur.presets.programs.dotfiles = {
    enable = lib.mkEnableOption "Clone dotfiles repository";
    repo = lib.mkOption {
      type = lib.types.str;
      description = "Git repo containing dotfiles";
      default = "git@github.com:nmasur/dotfiles";
    };
    path = lib.mkOption {
      type = lib.types.path;
      description = "Path to dotfiles on disk";
      default = config.home.homeDirectory + "/dev/personal/dotfiles";
    };
  };

  config = lib.mkIf cfg.enable {

    # Always make the dotfiles directory considered safe for git and direnv
    programs.git.extraConfig.safe.directory = cfg.path;
    programs.direnv.config.whitelist.prefix = [ cfg.path ];

    home.activation = {

      # Always clone dotfiles repository if it doesn't exist
      cloneDotfiles = config.lib.dag.entryAfter [ "writeBoundary" "loadkey" ] ''
        if [ -f ~/.ssh/id_ed25519 ]; then
            if [ ! -d "${cfg.path}" ]; then
                run mkdir --parents $VERBOSE_ARG $(dirname "${cfg.path}")
                run ${lib.getExe pkgs.git} clone ${cfg.repo} "${cfg.path}"
            fi
        fi
      '';
    };

    # Set a variable for dotfiles repo, not necessary but convenient
    home.sessionVariables.DOTS = cfg.path;
  };
}
