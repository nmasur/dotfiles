{ config, pkgs, lib, ... }: {

  config = lib.mkIf (config.physical && pkgs.stdenv.isLinux) {

    # Prevent wake from keyboard
    powerManagement.powerDownCommands = ''
      set +e

      for power in /sys/bus/i2c/devices/i2c-*/device/power; do echo disabled > ''${power}/wakeup || true; done
      for power in /sys/bus/usb/devices/1-*/device/power; do echo disabled > ''${power}/wakeup || true; done

      # Fix for Gigabyte motherboard
      # /r/archlinux/comments/y7b97e/my_computer_wakes_up_immediately_after_i_suspend/isu99sr/
      echo GPP0 > /proc/acpi/wakeup

      set -e
    '';

  };

}
