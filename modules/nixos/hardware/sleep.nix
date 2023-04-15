{ config, pkgs, lib, ... }: {

  config = lib.mkIf (config.physical && pkgs.stdenv.isLinux) {

    # Prevent wake from keyboard
    powerManagement.powerDownCommands = ''
      set +e

      for power in /sys/bus/i2c/devices/i2c-*/device/power; do echo disabled > ''${power}/wakeup || true; done
      for power in /sys/bus/usb/devices/1-*/power; do echo disabled > ''${power}/wakeup || true; done

      # Fix for Gigabyte motherboard
      # /r/archlinux/comments/y7b97e/my_computer_wakes_up_immediately_after_i_suspend/isu99sr/
      echo GPP0 > /proc/acpi/wakeup

      # Possibly need to wait a beat for settings to kick in
      sleep 2

      set -e
    '';

    services.udev.extraRules = ''
      ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/wakeup}="disabled"
      ACTION=="add", SUBSYSTEM=="i2c", ATTR{power/wakeup}="disabled"
    '';

  };

}
