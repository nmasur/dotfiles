{ config, pkgs, lib, ... }: {

  config = lib.mkIf (config.physical && config.isLinux) {

    # Enables wireless support via wpa_supplicant.
    networking.wireless.enable = true;

    # Allows the user to control the WiFi settings.
    networking.wireless.userControlled.enable = true;

  };

}
