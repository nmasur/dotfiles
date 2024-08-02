{
  config,
  pkgs,
  lib,
  ...
}:
{

  config = lib.mkIf config.gui.enable {

    # Mouse customization
    services.ratbagd.enable = true;

    environment.systemPackages = with pkgs; [
      libratbag # Mouse adjustments
      piper # Mouse adjustments GUI
    ];

    services.libinput.mouse = {
      # Disable mouse acceleration
      accelProfile = "flat";
      accelSpeed = "1.15";
    };

    # Cursor
    home-manager.users.${config.user}.home.pointerCursor = {
      name = "Adwaita";
      package = pkgs.adwaita-icon-theme;
      size = 24;
      gtk.enable = true;
      x11.enable = true;
    };

  };
}
