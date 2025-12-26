{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.fish;
  inherit (config.nmasur.settings) username;
in

{

  options.nmasur.presets.programs.fish.enable = lib.mkEnableOption "Fish shell";

  config = lib.mkIf cfg.enable {
    programs.fish.enable = true;

    environment.shells = [ pkgs.fish ];

    users.users.${username}.shell = pkgs.fish;

    # Speeds up fish launch time on macOS
    programs.fish.useBabelfish = true;

    programs.fish.shellInit = ''
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
  };
}
