{ ... }: {

  networking.wireless.enable =
    true; # Enables wireless support via wpa_supplicant.
  networking.wireless.userControlled.enable = true;

}
