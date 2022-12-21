{ config, pkgs, lib, ... }: {

  config = lib.mkIf (config.physical && pkgs.stdenv.isLinux) {

    # Prevent wake from keyboard
    powerManagement.powerDownCommands = ''
      for wakeup in /sys/bus/usb/devices/1-*/power/wakeup; do echo disabled > $wakeup; done
    '';

  };

}
