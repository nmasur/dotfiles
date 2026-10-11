# The Arrow
# System configuration for temporary VM

rec {
  imports = [
    ({ modulesPath, ... }: {
      imports = [ "${modulesPath}/virtualisation/amazon-image.nix" ];
    })
  ];

  # Hardware
  networking.hostName = "arrow";

  # Ensure BIOS GRUB is used instead of server profile's systemd-boot
  boot.loader.systemd-boot.enable = false;
  boot.loader.grub.enable = true;

  # Resolves PermitRootLogin conflict with amazon-image.nix
  nmasur.presets.services.openssh-aws.enable = true;

  users.users.ssm-user.extraGroups = [ "wheel" ];

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
      power-user.enable = true;
      work-base.enable = true;
    };
    nmasur.presets.programs.git-work.work = {
      name = "Noah-Masur_1701";
      email = "${nmasur.settings.username}@take2games.com";
    };
    home.stateVersion = "26.05";
  };

  system.stateVersion = "26.05";

}
