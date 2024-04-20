{
  config,
  pkgs,
  lib,
  ...
}:
{

  options = {
    obsidian = {
      enable = lib.mkEnableOption {
        description = "Enable Obsidian.";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.gui.enable && config.obsidian.enable) {
    unfreePackages = [ "obsidian" ];
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [ obsidian ];
    };

    # Broken on 2023-12-11
    # https://forum.obsidian.md/t/electron-25-is-now-eol-please-upgrade-to-a-newer-version/72878/8
    nixpkgs.config.permittedInsecurePackages = [ "electron-25.9.0" ];
  };
}
