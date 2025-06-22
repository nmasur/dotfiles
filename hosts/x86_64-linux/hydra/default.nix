# The Hydra
# System configuration for WSL

rec {
  # Hardware
  networking.hostName = "hydra";

  nmasur.settings = {
    username = "noah";
    fullName = "Noah Masur";
  };

  nmasur.profiles = {
    base.enable = true;
    wsl.enable = true;
  };

  home-manager.users."noah" = {
    nmasur.settings = {
      username = nmasur.settings.username;
      fullName = nmasur.settings.fullName;
      host = networking.hostName;
    };
    nmasur.profiles = {
      common.enable = true;
      linux-base.enable = true;
      power-user.enable = true;
    };
    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05";

  # This is the root filesystem containing NixOS
  fileSystems."/" = {
    device = "/dev/disk/by-label/nixos";
    fsType = "ext4";
  };

  # This is the boot filesystem for Grub
  fileSystems."/boot" = {
    device = "/dev/disk/by-label/boot";
    fsType = "vfat";
  };

  # Not sure what's necessary but too afraid to remove anything
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];
}
