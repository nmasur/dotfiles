{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {

    # Mouse customization
    services.ratbagd.enable = true;

    environment.systemPackages = with pkgs; [
      libratbag # Mouse adjustments
      piper # Mouse adjustments GUI
    ];

    services.xserver.libinput.mouse = {
      # Disable mouse acceleration
      accelProfile = "flat";
      accelSpeed = "1.15";
    };

  };

}
