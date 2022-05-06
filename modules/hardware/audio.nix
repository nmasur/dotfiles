{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    environment.systemPackages = with pkgs;
      [
        pamixer # Audio control
      ];
  };

}
