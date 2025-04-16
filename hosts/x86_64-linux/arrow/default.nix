# The Arrow
# System configuration for temporary VM

rec {
  # Hardware
  networking.hostName = "arrow";

  nmasur.settings = {
    username = "noah";
    fullName = "Noah Masur";
  };

  nmasur.profiles = {
    base.enable = true;
    server.enable = true;
  };

  home-manager.users."noah" = {
    nmasur.settings = {
      username = nmasur.settings.username;
      fullName = nmasur.settings.fullName;
    };
    nmasur.profiles = {
      common.enable = true;
      linux-base.enable = true;
    };
    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05";

  # These filesystems are ignored by nixos-generators

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

}
