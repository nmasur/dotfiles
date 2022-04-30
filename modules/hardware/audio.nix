{ pkgs, lib, gui, ... }: {

  config = lib.mkIf gui.enable {
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    environment.systemPackages = with pkgs;
      [
        pamixer # Audio control
      ];
  };

}
