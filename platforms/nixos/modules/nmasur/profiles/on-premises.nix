{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.on-premises;
in

{

  options.nmasur.profiles.on-premises.enable = lib.mkEnableOption "on-premises machine settings";

  config = lib.mkIf cfg.enable {

    # Enable automatic timezone updates based on location
    services.tzupdate.enable = true;

    # Allow reading from Windows drives
    boot.supportedFilesystems = [ "ntfs" ];

    # Enable fstrim, which tracks free space on SSDs for garbage collection
    # More info: https://www.reddit.com/r/NixOS/comments/rbzhb1/if_you_have_a_ssd_dont_forget_to_enable_fstrim/
    services.fstrim.enable = true;

    networking.useDHCP = !config.networking.networkmanager.enable;

    networking.wireless = {
      # Enables wireless support via wpa_supplicant.
      enable = !config.networking.networkmanager.enable;

      # Allows the user to control the WiFi settings.
      userControlled.enable = true;
    };

    # Wake up tempest with a command
    environment.systemPackages = [
      (pkgs.writeShellScriptBin "wake-tempest" "${pkgs.wakeonlan}/bin/wakeonlan --ip=192.168.1.255 74:56:3C:40:37:5D")
    ];

  };
}
