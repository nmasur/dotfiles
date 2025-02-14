{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.server;
in

{

  options.nmasur.profiles.server.enable = lib.mkEnableOption "server configuration";

  config = lib.mkIf cfg.enable {

    networking.firewall.allowPing = lib.mkDefault true;

    nmasur.presets.services.openssh.enable = lib.mkDefault true;

    # Implement a simple fail2ban service for sshd
    services.sshguard.enable = lib.mkDefault true;

    # Servers need a bootloader or they won't start
    boot.loader.systemd-boot.enable = lib.mkDefault true;
    boot.loader.efi.canTouchEfiVariables = lib.mkDefault true;
  };
}
