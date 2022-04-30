{ pkgs, lib, gui, ... }: {

  config = lib.mkIf gui.enable {

    # Mouse config
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
