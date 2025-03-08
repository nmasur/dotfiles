{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.nix-index;
in

{

  options.nmasur.presets.programs.nix-index.enable =
    lib.mkEnableOption "nix-index caching for command line";

  config = lib.mkIf cfg.enable {

    # Provides "command-not-found" options
    programs.nix-index = {
      enable = true;
      enableFishIntegration = true;
    };

    # Create nix-index if doesn't exist
    home.activation.createNixIndex =
      let
        cacheDir = "${config.xdg.cacheHome}/nix-index";
      in
      lib.mkIf config.programs.nix-index.enable (
        config.lib.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d ${cacheDir} ]; then
              run ${pkgs.nix-index}/bin/nix-index -f ${pkgs.path}
          fi
        ''
      );

  };

}
