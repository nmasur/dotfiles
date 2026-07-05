{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.fish-darwin;
in

{

  options.nmasur.presets.programs.fish-darwin.enable = lib.mkEnableOption {
    description = "Fish macOS options";
  };

  config = lib.mkIf cfg.enable {
    # Default shell setting doesn't work
    home.sessionVariables = {
      SHELL = "${pkgs.fish}/bin/fish";
    };

    programs.fish = {
      shellAbbrs = {
        # Shortcut to edit hosts file
        hosts = "sudo hx /etc/hosts";
      };
      shellInit = ''
        set -g __nixos_path_original $PATH
        function __nixos_path_fix -d "fix PATH value"
          set -l result (string split ":" $__nixos_path_original)
          for elt in $PATH
            if not contains -- $elt $result
              set -a result $elt
            end
          end
          set -g PATH $result
        end
        __nixos_path_fix
      '';

      # # Speeds up fish launch time on macOS
      # useBabelfish = true;
    };
  };
}
