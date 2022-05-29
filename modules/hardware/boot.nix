{ ... }: {

  # Use the systemd-boot EFI boot loader.
  # These came with the system and I don't know if they're required.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

}
