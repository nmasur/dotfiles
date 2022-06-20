{ config, ... }: {

  boot.loader = {
    grub = {
      enable = true;

      # Not sure what this does, but it involves the UEFI/BIOS
      efiSupport = true;

      # Check for other OSes and make them available
      useOSProber = true;

      # Install GRUB onto the boot disk
      # device = config.fileSystems."/boot".device;

      # Don't install GRUB, required for UEFI?
      device = "nodev";

      # Display menu indefinitely if holding shift key
      extraConfig = ''
        if keystatus --shift ; then
            set timeout=-1
        else
            set timeout=0
        fi
      '';
    };

    # Always display menu indefinitely; default is 5 seconds
    # timeout = null;

    # Allows GRUB to interact with the UEFI/BIOS I guess
    efi.canTouchEfiVariables = true;
  };
}
