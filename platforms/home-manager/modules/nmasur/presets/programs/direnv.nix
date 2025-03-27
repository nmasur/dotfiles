{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.direnv;
in

{

  options.nmasur.presets.programs.direnv.enable = lib.mkEnableOption "Direnv project-level shells";

  config = lib.mkIf cfg.enable {
    # Enables quickly entering Nix shells when changing directories
    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
    };
  };
}
