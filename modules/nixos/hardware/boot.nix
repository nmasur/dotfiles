{
  config,
  pkgs,
  lib,
  ...
}:
{

  boot.loader = lib.mkIf (config.physical && !config.server) {
    grub = {
      enable = true;

      # Not sure what this does, but it involves the UEFI/BIOS
      efiSupport = true;

      # Check for other OSes and make them available
      useOSProber = true;

      # Attempt to display GRUB on widescreen monitor
      gfxmodeEfi = "1920x1080";

      # Limit the total number of configurations to rollback
      configurationLimit = 25;

      # Install GRUB onto the boot disk
      # device = config.fileSystems."/boot".device;

      # Don't install GRUB, required for UEFI?
      device = "nodev";

      # Display menu indefinitely if holding shift key
      extraConfig = ''
        if keystatus --shift ; then
            set timeout=-1
        else
            set timeout=3
        fi
      '';
    };

    # Always display menu indefinitely; default is 5 seconds
    # timeout = null;

    # Allows GRUB to interact with the UEFI/BIOS I guess
    efi.canTouchEfiVariables = true;
  };

  # Allow reading from Windows drives
  boot.supportedFilesystems = lib.mkIf config.physical [ "ntfs" ];

  # Use latest released Linux kernel by default
  boot.kernelPackages = lib.mkDefault pkgs.linuxPackages_latest;
}
