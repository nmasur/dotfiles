{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.nixpkgs-darwin;
in

{

  options.nmasur.presets.programs.nixpkgs-darwin.enable = lib.mkEnableOption {
    description = "Nixpkgs tools for macOS";
    default = config.nmasur.presets.programs.nixpkgs && pkgs.stdenv.isDarwin;
  };

  config = lib.mkIf (cfg.enable) {

    programs.fish = {
      shellAbbrs = {
        nr = {
          function = lib.mkForce "rebuild-darwin";
        };
        nro = {
          function = lib.mkForce "rebuild-darwin-offline";
        };
      };
      functions = {
        rebuild-darwin = {
          body = ''
            git -C ${config.dotfilesPath} add --intent-to-add --all
            echo "darwin-rebuild switch --flake ${config.dotfilesPath}#lookingglass"
          '';
        };
        rebuild-darwin-offline = {
          body = ''
            git -C ${config.dotfilesPath} add --intent-to-add --all
            echo "darwin-rebuild switch --option substitute false --flake ${config.dotfilesPath}#lookingglass"
          '';
        };
        rebuild-home = lib.mkForce {
          body = ''
            git -C ${config.dotfilesPath} add --intent-to-add --all
            echo "${pkgs.home-manager}/bin/home-manager switch --flake ${config.dotfilesPath}#lookingglass";
          '';
        };
      };
    };

  };
}
