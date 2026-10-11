# The Arrow
# System configuration for temporary VM

rec {
  # Hardware
  networking.hostName = "arrow";
  aws.enable = true;

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
      host = networking.hostName;
    };
    nmasur.profiles = {
      common.enable = true;
      linux-base.enable = true;
      llm-development.enable = true;
    };
    nmasur.presets.programs.git-work.work = {
      name = "Noah-Masur_1701";
      email = "${nmasur.settings.username}@take2games.com";
    };
    home.stateVersion = "26.05";
  };

  system.stateVersion = "26.05";

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
