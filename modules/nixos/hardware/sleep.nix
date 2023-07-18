{ config, pkgs, lib, ... }: {

  config = lib.mkIf (config.physical && !config.server) {

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
