{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.server;
in

{

  options.nmasur.profiles.server.enable = lib.mkEnableOption "server configuration";

  config = lib.mkIf cfg.enable {

    networking.firewall.allowPing = true;

    # Implement a simple fail2ban service for sshd
    services.sshguard.enable = true;

    # Servers need a bootloader or they won't start
    boot.loader.systemd-boot.enable = true;
    boot.loader.efi.canTouchEfiVariables = true;

    # Use power button to sleep instead of poweroff
    services.logind.powerKey = "suspend";
    services.logind.powerKeyLongPress = "poweroff";

    # Prevent wake from keyboard
    powerManagement.powerDownCommands = ''
      set +e

      # Fix for Gigabyte motherboard
      # /r/archlinux/comments/y7b97e/my_computer_wakes_up_immediately_after_i_suspend/isu99sr/
      # Disable if enabled
      if (grep "GPP0.*enabled" /proc/acpi/wakeup >/dev/null); then
          echo GPP0 | ${pkgs.doas}/bin/doas tee /proc/acpi/wakeup
      fi

      sleep 2

      set -e
    '';
    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/wakeup}="disabled"
      ACTION=="add", SUBSYSTEM=="i2c", ATTR{power/wakeup}="disabled"
    '';

  };
}
