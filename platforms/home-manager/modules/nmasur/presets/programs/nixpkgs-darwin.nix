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
    default =
      config.nmasur.presets.programs.nixpkgs.enable
      && pkgs.stdenv.isDarwin
      && config.nmasur.presets.programs.dotfiles.enable;
  };

  config = lib.mkIf (cfg.enable) {

    programs.fish = {
      shellAbbrs = lib.mkIf config.nmasur.presets.programs.dotfiles.enable {
        nr = {
          function = lib.mkForce "rebuild-darwin";
        };
        nro = {
          function = lib.mkForce "rebuild-darwin-offline";
        };
      };
      functions = lib.mkIf config.nmasur.presets.programs.dotfiles.enable {
        rebuild-darwin = {
          body = ''
            git -C ${config.nmasur.presets.programs.dotfiles.path} add --intent-to-add --all
            echo "darwin-rebuild switch --flake ${config.nmasur.presets.programs.dotfiles.path}#lookingglass"
          '';
        };
        rebuild-darwin-offline = {
          body = ''
            git -C ${config.nmasur.presets.programs.dotfiles.path} add --intent-to-add --all
            echo "darwin-rebuild switch --option substitute false --flake ${config.nmasur.presets.programs.dotfiles.path}#lookingglass"
          '';
        };
        rebuild-home = lib.mkForce {
          body = ''
            git -C ${config.nmasur.presets.programs.dotfiles.path} add --intent-to-add --all
            echo "${lib.getExe pkgs.home-manager} switch --flake ${config.nmasur.presets.programs.dotfiles.path}#lookingglass";
          '';
        };
      };
    };

  };
}
