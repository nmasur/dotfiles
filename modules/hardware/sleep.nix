{ ... }: {

  # Prevent wake from keyboard
  powerManagement.powerDownCommands = ''
    echo disabled > /sys/bus/usb/devices/1-6/power/wakeup
  '';

}
