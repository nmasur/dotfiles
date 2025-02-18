# The Swan
# System configuration for my home NAS server

rec {
  networking.hostName = "swan";

  nmasur.settings = {
    username = "noah";
    fullName = "Noah Masur";
    # hostnames =
    #   let
    #     baseName = "masu.rs";
    #   in
    #   {
    #     audiobooks = "read.${baseName}";
    #     books = "books.${baseName}";
    #     content = "cloud.${baseName}";
    #     download = "download.${baseName}";
    #     files = "files.${baseName}";
    #     paperless = "paper.${baseName}";
    #     photos = "photos.${baseName}";
    #     prometheus = "prom.${baseName}";
    #     stream = "stream.${baseName}";
    #   };
  };

  nmasur.profiles = {
    base.enable = true;
    server.enable = true;
    home.enable = true;
    nas.enable = true;
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
    devices = (import ../../disks/root.nix { disk = "/dev/nvme0n1"; });
  };

  # Allows private remote access over the internet
  nmasur.presets.services.cloudflared = {
    tunnel = {
      id = "646754ac-2149-4a58-b51a-e1d0a1f3ade2";
      credentialsFile = ../../private/cloudflared-swan.age;
      ca = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBCHF/UMtJqPFrf6f6GRY0ZFnkCW7b6sYgUTjTtNfRj1RdmNic1NoJZql7y6BrqQinZvy7nsr1UFDNWoHn6ah3tg= open-ssh-ca@cloudflareaccess.org";
    };
  };
}
