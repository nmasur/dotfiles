{ config, lib, ... }:

let
  inherit (config.nmasur.settings) username;
  cfg = config.nmasur.profiles.wsl;
in

{
  options.nmasur.profiles.wsl.enable = lib.mkEnableOption "WSL settings";

  config = lib.mkIf cfg.enable {

    wsl = {
      enable = true;
      wslConf.automount.root = lib.mkDefault "/mnt";
      defaultUser = lib.mkDefault username;
      startMenuLaunchers = lib.mkDefault true;
      nativeSystemd = lib.mkDefault true;
      wslConf.network.generateResolvConf = lib.mkDefault true; # Turn off if it breaks VPN
      interop.includePath = lib.mkDefault false; # Including Windows PATH will slow down Neovim command mode
    };

    # # Replace config directory with our repo, since it sources from config on
    # # every launch
    # system.activationScripts.configDir.text = ''
    #   rm -rf /etc/nixos
    #   ln --symbolic --no-dereference --force ${config.dotfilesPath} /etc/nixos
    # '';

  };

}
