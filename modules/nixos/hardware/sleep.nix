{ config, pkgs, lib, ... }: {

  config = lib.mkIf (config.physical && pkgs.stdenv.isLinux) {

    # Prevent wake from keyboard
    powerManagement.powerDownCommands = ''
      # for power in /sys/bus/usb/devices/*/power; do echo disabled > ''${power}/wakeup; done

      # AMD issue: https://wiki.archlinux.org/title/Power_management/Suspend_and_hibernate#Instantaneous_wakeups_from_suspend
      for power in /sys/bus/i2c/devices/i2c-*/device/power; do echo disabled > ''${power}/wakeup; done
    '';

    # From here: https://www.reddit.com/r/NixOS/comments/wcu34f/how_would_i_do_this_in_nix/
    # services.udev.extraRules = ''
    #   ACTION=="add", SUBSYSTEM=="i2c", ATTRS{idVendor}=="<vendor>", ATTRS{idProduct}=="<product>" RUN+="${pkgs.bash}/bin/bash -c 'echo disabled > /sys/bus/i2c/devices/i2c-*/power/wakeup'"
    # '';

  };

}
