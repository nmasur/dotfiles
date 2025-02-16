{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.obsidian;
in
{

  options = {
    nmasur.presets.programs.obsidian = {
      enable = lib.mkEnableOption "Obsidian markdown wiki";
    };
  };

  config = lib.mkIf cfg.enable {
    unfreePackages = [ "obsidian" ];
    home.packages = with pkgs; [ obsidian ];

    # Broken on 2023-12-11
    # https://forum.obsidian.md/t/electron-25-is-now-eol-please-upgrade-to-a-newer-version/72878/8
    # insecurePackages = [ "electron-25.9.0" ];
  };
}
