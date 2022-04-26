# Edit this configuration file to define what should be installed on
# your system.  Help is available in the configuration.nix(5) man page
# and in the NixOS manual (accessible by running ‘nixos-help’).

{ config, pkgs, ... }:

{
  imports = [ # Include the results of the hardware scan.
    /etc/nixos/hardware-configuration.nix
    ../modules/system/timezone.nix
    ../modules/system/doas.nix
    ../modules/gaming
  ];

  nixpkgs.config.allowUnfree = true;
  nix.extraOptions = "experimental-features = nix-command flakes";

  # Use the systemd-boot EFI boot loader.
  boot.loader.systemd-boot.enable = true;
  boot.loader.efi.canTouchEfiVariables = true;

  # networking.hostName = "nixos"; # Define your hostname.
  # networking.wireless.enable = true;  # Enables wireless support via wpa_supplicant.

  # The global useDHCP flag is deprecated, therefore explicitly set to false here.
  # Per-interface useDHCP will be mandatory in the future, so this generated config
  # replicates the default behaviour.
  networking.useDHCP = false;
  networking.interfaces.enp0s31f6.useDHCP = true;
  networking.interfaces.wlp3s0.useDHCP = true;

  # Enable the X11 windowing system.
  services.xserver = {
    enable = true;

    windowManager = { i3 = { enable = true; }; };

    # Enable touchpad support
    libinput.enable = true;

    # Disable mouse acceleration
    libinput.mouse.accelProfile = "flat";
    libinput.mouse.accelSpeed = "1.15";

    # Keyboard responsiveness
    autoRepeatDelay = 250;
    autoRepeatInterval = 40;

    # Configure keymap in X11
    layout = "us";
    xkbOptions = "eurosign:e,caps:swapescape";

    # Login screen
    displayManager = {
      lightdm = {
        enable = true;

        # Make the login screen dark
        greeters.gtk.theme.name = "Adwaita-dark";

        # Put the login screen on the left monitor
        greeters.gtk.extraConfig = ''
          active-monitor=0
        '';
      };
      setupCommands = ''
        ${pkgs.xorg.xrandr}/bin/xrandr --output DisplayPort-0 \
                                            --mode 1920x1200 \
                                            --pos 1920x0 \
                                            --rotate left \
                                        --output HDMI-0 \
                                            --primary \
                                            --mode 1920x1080 \
                                            --pos 0x559 \
                                            --rotate normal \
                                        --output DVI-0 --off \
                                        --output DVI-1 --off \
      '';
    };

  };

  # Required for setting GTK theme (for preferred-color-scheme in browser)
  services.dbus.packages = with pkgs; [ pkgs.dconf ];

  # Mouse config
  services.ratbagd.enable = true;

  # Enable sound.
  sound.enable = true;
  hardware.pulseaudio.enable = true;

  # Install fonts
  fonts.fonts = with pkgs; [
    victor-mono # Used for Vim and Terminal
    nerdfonts # Used for icons in Vim
    font-awesome # Icons for i3
    # siji # More icons for Polybar
  ];
  fonts.fontconfig.defaultFonts.monospace = [ "Victor Mono" ];

  # Define a user account. Don't forget to set a password with ‘passwd’.
  users.users.noah = {

    # Create a home directory for human user
    isNormalUser = true;

    # Automatically create a password to start
    initialPassword = "changeme";

    # Enable sudo privileges
    extraGroups = [
      "wheel" # Sudo privileges
      "i2c" # Access to external monitors
    ];

    # Use the fish shell
    shell = pkgs.fish;
  };

  # List packages installed in system profile. To search, run:
  # $ nix search wget
  environment.systemPackages = with pkgs; [
    fish
    vim
    wget
    curl
    home-manager
    xclip # Clipboard
    pamixer # Audio control
    dmenu # Launcher
    feh # Wallpaper
    playerctl # Media control
    polybarFull # Polybar + PulseAudio
    ddcutil # Monitor brightness control

    # Mouse config
    libratbag # Mouse adjustments
    piper # Mouse adjustments GUI
  ];

  # Reduce blue light at night
  services.redshift = {
    enable = true;
    brightness = {
      day = "1.0";
      night = "1.0";
    };
  };

  # Detect monitors (brightness)
  hardware.i2c.enable = true;

  # Some programs need SUID wrappers, can be configured further or are
  # started in user sessions.
  # programs.mtr.enable = true;
  # programs.gnupg.agent = {
  #   enable = true;
  #   enableSSHSupport = true;
  # };

  # This value determines the NixOS release from which the default
  # settings for stateful data, like file locations and database versions
  # on your system were taken. It‘s perfectly fine and recommended to leave
  # this value at the release version of the first install of this system.
  # Before changing this value read the documentation for this option
  # (e.g. man configuration.nix or on https://nixos.org/nixos/options.html).
  system.stateVersion = "21.11"; # Did you read the comment?

}
