{ config, ... }: {

  # Servers need a bootloader or they won't start
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

}
