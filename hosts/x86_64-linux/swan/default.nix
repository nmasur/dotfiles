# The Swan
# System configuration for my home NAS server

rec {
  networking.hostName = "swan";

  nmasur.settings = {
    username = "noah";
    fullName = "Noah Masur";
  };

  nmasur.profiles = {
    base.enable = true;
    server.enable = true;
    home.enable = true;
    nas.enable = true;
    shared-media.enable = true;
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

  # Not sure what's necessary but too afraid to remove anything
  boot.initrd.availableKernelModules = [
    "xhci_pci"
    "ahci"
    "nvme"
    "usb_storage"
    "sd_mod"
  ];

  # Required for transcoding
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelParams = [
    "radeon.si_support=0"
    "amdgpu.si_support=1"
    "radeon.cik_support=0"
    "amdgpu.cik_support=1"
    "amdgpu.dc=1"
  ];

  # Required binary blobs to boot on this machine
  hardware.enableRedistributableFirmware = true;

  # Prioritize efficiency over performance
  powerManagement.cpuFreqGovernor = "powersave";

  # Allow firmware updates
  hardware.cpu.intel.updateMicrocode = true;

  # ZFS
  # Generated with: head -c 8 /etc/machine-id
  networking.hostId = "600279f4"; # Random ID required for ZFS

  # Sets root ext4 filesystem instead of declaring it manually
  disko = {
    enableConfig = true;
    devices = (import ./root.nix { disk = "/dev/nvme0n1"; });
  };

  # Allows private remote access over the internet
  nmasur.presets.services.cloudflared = {
    tunnel = {
      id = "646754ac-2149-4a58-b51a-e1d0a1f3ade2";
      credentialsFile = ./cloudflared-swan.age;
      ca = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCHF/UMtJqPFrf6f6GRY0ZFnkCW7b6sYgUTjTtNfRj1RdmNic1NoJZql7y6BrqQinZvy7nsr1UFDNWoHn6ah3tg= open-ssh-ca@cloudflareaccess.org";
    };
  };
}
