# The Tempest
# System configuration for my desktop

rec {
  # Hardware
  networking.hostName = "tempest";

  nmasur.settings = {
    username = "noah";
    fullName = "Noah Masur";
  };

  nmasur.profiles = {
    base.enable = true;
    home.enable = true;
    gui.enable = true;
    gaming.enable = true;
  };

  nmasur.presets.services.grub.enable = true;

  home-manager.users."noah" = {
    nmasur.settings = {
      username = nmasur.settings.username;
      fullName = nmasur.settings.fullName;
    };
    nmasur.profiles = {
      common.enable = true;
      linux-base.enable = true;
      linux-gui.enable = true;
      linux-gaming.enable = true;
      power-user.enable = true;
      developer.enable = true;
      experimental.enable = true;
    };
    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05";

  # Not sure what's necessary but too afraid to remove anything
  boot.initrd.availableKernelModules = [
    "nvme"
    "xhci_pci"
    "ahci"
    "usb_storage"
    "usbhid"
    "sd_mod"
  ];

  # Graphics and VMs
  boot.initrd.kernelModules = [ "amdgpu" ];
  boot.kernelModules = [ "kvm-amd" ];
  services.xserver.videoDrivers = [ "amdgpu" ];

  # Required binary blobs to boot on this machine
  hardware.enableRedistributableFirmware = true;

  # Prioritize performance over efficiency
  powerManagement.cpuFreqGovernor = "performance";

  # Allow firmware updates
  hardware.cpu.amd.updateMicrocode = true;

  # Helps reduce GPU fan noise under idle loads
  hardware.fancontrol.enable = true;
  hardware.fancontrol.config = ''
    # Configuration file generated by pwmconfig, changes will be lost
    INTERVAL=10
    DEVPATH=hwmon0=devices/pci0000:00/0000:00:03.1/0000:06:00.0/0000:07:00.0/0000:08:00.0
    DEVNAME=hwmon0=amdgpu
    FCTEMPS=hwmon0/pwm1=hwmon0/temp1_input
    FCFANS= hwmon0/pwm1=hwmon0/fan1_input
    MINTEMP=hwmon0/pwm1=50
    MAXTEMP=hwmon0/pwm1=70
    MINSTART=hwmon0/pwm1=100
    MINSTOP=hwmon0/pwm1=10
    MINPWM=hwmon0/pwm1=10
    MAXPWM=hwmon0/pwm1=240
  '';

  # File systems must be declared in order to boot

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
  nmasur.presets.services.cloudflared = {
    tunnel = {
      id = "ac133a82-31fb-480c-942a-cdbcd4c58173";
      credentialsFile = ./cloudflared-tempest.age;
      ca = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBPY6C0HmdFCaxYtJxFr3qV4/1X4Q8KrYQ1hlme3u1hJXK+xW+lc9Y9glWHrhiTKilB7carYTB80US0O47gI5yU4= open-ssh-ca@cloudflareaccess.org";
    };
  };

  # Allows requests to force machine to wake up
  # This network interface might change, needs to be set specifically for each machine.
  # Or set usePredictableInterfaceNames = false
  networking.interfaces.enp5s0.wakeOnLan.enable = true;
}
