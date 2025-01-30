{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.dotfiles;
in
{

  # Allows me to make sure I can work on my dotfiles locally

  options.nmasur.preset.services.dotfiles = {
    enable = lib.mkEnableOption "Clone dotfiles repository";
    repo = lib.mkOption {
      type = lib.types.str;
      description = "Git repo containing dotfiles";
      default = "git@github.com:nmasur/dotfiles";
    };
    path = lib.mkOption {
      type = lib.types.path;
      description = "Path to dotfiles on disk";
      default = config.homePath + "/dev/personal/dotfiles";
    };
  };

  config = lib.mkIf cfg.enable {

    home.activation = {

      # Always clone dotfiles repository if it doesn't exist
      cloneDotfiles = config.lib.dag.entryAfter [ "writeBoundary" "loadkey" ] ''
        if [ ! -d "${cfg.path}" ]; then
            run mkdir --parents $VERBOSE_ARG $(dirname "${cfg.path}")
            run ${pkgs.git}/bin/git \
                clone ${cfg.repo} "${cfg.path}"
        fi
      '';
    };

    # Set a variable for dotfiles repo, not necessary but convenient
    home.sessionVariables.DOTS = cfg.path;
  };
}
