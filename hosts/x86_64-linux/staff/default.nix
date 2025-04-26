# The Staff
# System configuration test

rec {
  # Hardware
  networking.hostName = "staff";

  nmasur.settings = {
    username = "noah";
    fullName = "Noah Masur";
  };

  nmasur.profiles = {
    base.enable = true;
    home.enable = true;
    gui.enable = true;
  };
  nmasur.presets.services.cloudflared.enable = false;
  nmasur.presets.services.kanata.enable = false;
  nmasur.presets.services.openssh.enable = true;

  home-manager.users."noah" = {
    nmasur.settings = {
      username = nmasur.settings.username;
      fullName = nmasur.settings.fullName;
    };
    nmasur.profiles = {
      common.enable = true;
      linux-base.enable = true;
      linux-gui.enable = true;
      power-user.enable = true;
    };
    nmasur.presets.services.mbsync = {
      user = nmasur.settings.username;
      server = "noahmasur.com";
    };
    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05";
  # Not sure what's necessary but too afraid to remove anything
  # File systems must be declared in order to boot

  # Required to have a boot loader to work
  boot.loader.systemd-boot.enable = true;

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

  # Allows private remote access over the internet
  # nmasur.presets.services.cloudflared = {
  #   tunnel = {
  #     id = "ac133a82-31fb-480c-942a-cdbcd4c58173";
  #     credentialsFile = ../../private/cloudflared-tempest.age;
  #     ca = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPY6C0HmdFCaxYtJxFr3qV4/1X4Q8KrYQ1hlme3u1hJXK+xW+lc9Y9glWHrhiTKilB7carYTB80US0O47gI5yU4= open-ssh-ca@cloudflareaccess.org";
  #   };
  # };
}
