{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.home;
in

{

  options.nmasur.profiles.home.enable =
    lib.mkEnableOption "home (on-premises, physical) machine settings";

  config = lib.mkIf cfg.enable {

    nmasur.presets.services = {
      # Configure physical power buttons
      logind.enable = lib.mkDefault true;
    };

    # Enable automatic timezone updates based on location
    services.automatic-timezoned.enable = lib.mkDefault true;

    # Allow reading from Windows drives
    boot.supportedFilesystems = [ "ntfs" ];

    # Enable fstrim, which tracks free space on SSDs for garbage collection
    # More info: https://www.reddit.com/r/NixOS/comments/rbzhb1/if_you_have_a_ssd_dont_forget_to_enable_fstrim/
    services.fstrim.enable = lib.mkDefault true;

    networking.useDHCP = lib.mkDefault (!config.networking.networkmanager.enable);

    networking.wireless = {
      # Enables wireless support via wpa_supplicant.
      enable = lib.mkDefault (!config.networking.networkmanager.enable);

      # Allows the user to control the WiFi settings.
      userControlled.enable = lib.mkDefault true;
    };

    # Wake up tempest with a command
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "wake-tempest" "${lib.getExe pkgs.wakeonlan} --ip=192.168.1.255 74:56:3C:40:37:5D")
    ];

    # Prevent wake from keyboard
    powerManagement.powerDownCommands =
      lib.mkDefault # bash
        ''
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
    services.udev.extraRules = lib.mkDefault ''
      ACTION=="add", SUBSYSTEM=="usb", DRIVER=="usb", ATTR{power/wakeup}="disabled"
      ACTION=="add", SUBSYSTEM=="i2c", ATTR{power/wakeup}="disabled"
    '';

  };
}
