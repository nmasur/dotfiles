{ config, lib, ... }:

let
  cfg = config.nmasur.profiles.wsl;
in

{
  options.nmasur.profiles.wsl.enable = lib.mkEnableOption "WSL settings";

  config = lib.mkIf cfg.enable {

    # Replace config directory with our repo, since it sources from config on
    # every launch
    system.activationScripts.configDir.text = ''
      rm -rf /etc/nixos
      ln --symbolic --no-dereference --force ${config.dotfilesPath} /etc/nixos
    '';

  };

}
