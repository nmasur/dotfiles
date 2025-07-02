# The Flame
# System configuration for an Oracle free server

# How to install:
# https://blog.korfuri.fr/posts/2022/08/nixos-on-an-oracle-free-tier-ampere-machine/
# These days, probably use nixos-anywhere instead.

rec {
  networking.hostName = "flame";

  nmasur.settings = {
    username = "noah";
    fullName = "Noah Masur";
  };

  nmasur.profiles = {
    base.enable = true;
    server.enable = true;
    communications.enable = true;
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
    nmasur.presets.programs.helix.enable = true;
    home.stateVersion = "23.05";
  };

  system.stateVersion = "23.05";
  # File systems must be declared in order to boot

  # # This is the root filesystem containing NixOS
  # # I forgot to set a clean label for it
  # fileSystems."/" = {
  #   device = "/dev/disk/by-uuid/e1b6bd50-306d-429a-9f45-78f57bc597c3";
  #   fsType = "ext4";
  # };

  # # This is the boot filesystem for systemd-boot
  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-uuid/D5CA-237A";
  #   fsType = "vfat";
  # };

  # Allows private remote access over the internet
  nmasur.presets.services.cloudflared = {
    tunnel = {
      id = "bd250ee1-ed2e-42d2-b627-039f1eb5a4d2";
      credentialsFile = ./cloudflared-flame.age;
      ca = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBK/6oyVqjFGX3Uvrc3VS8J9sphxzAnRzKC85xgkHfYgR3TK6qBGXzHrknEj21xeZrr3G2y1UsGzphWJd9ZfIcdA= open-ssh-ca@cloudflareaccess.org";
    };
  };

  # Taken from https://github.com/NixOS/nixpkgs/blob/master/nixos/modules/virtualisation/oci-common.nix

  # fileSystems."/" = {
  #   device = "/dev/disk/by-label/nixos";
  #   fsType = "ext4";
  #   autoResize = true;
  # };

  # fileSystems."/boot" = {
  #   device = "/dev/disk/by-label/ESP";
  #   fsType = "vfat";
  # };

  boot.loader.efi.canTouchEfiVariables = false;
  boot.loader.grub = {
    device = "nodev";
    splashImage = null;
    extraConfig = ''
      serial --unit=0 --speed=115200 --word=8 --parity=no --stop=1
      terminal_input --append serial
      terminal_output --append serial
    '';
    efiInstallAsRemovable = true;
    efiSupport = true;
  };

  # https://docs.oracle.com/en-us/iaas/Content/Compute/Tasks/configuringntpservice.htm#Configuring_the_Oracle_Cloud_Infrastructure_NTP_Service_for_an_Instance
  networking.timeServers = [ "169.254.169.254" ];

  services.openssh.enable = true;

  # Example to create a bios compatible gpt partition
  disko.devices = {
    disk.disk1 = {
      device = "/dev/sda";
      type = "disk";
      content = {
        type = "gpt";
        partitions = {
          boot = {
            name = "boot";
            size = "1M";
            type = "EF02";
          };
          esp = {
            name = "ESP";
            size = "500M";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          };
          root = {
            name = "root";
            size = "100%";
            content = {
              type = "lvm_pv";
              vg = "pool";
            };
          };
        };
      };
    };
    lvm_vg = {
      pool = {
        type = "lvm_vg";
        lvs = {
          root = {
            size = "100%FREE";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              mountOptions = [
                "defaults"
              ];
            };
          };
        };
      };
    };
  };

  # # Otherwise the instance may not have a working network-online.target,
  # # making the fetch-ssh-keys.service fail
  # networking.useNetworkd = true;
}
