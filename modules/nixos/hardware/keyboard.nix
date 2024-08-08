{ config, lib, ... }:
{

  config = lib.mkIf config.physical {

    services.xserver = {

      xkb.layout = "us";

      # Keyboard responsiveness
      autoRepeatDelay = 250;
      autoRepeatInterval = 40;
    };

    # Swap Caps-Lock with Escape when pressed or LCtrl when held/combined with others
    # Inspired by: https://www.youtube.com/watch?v=XuQVbZ0wENE
    services.kanata = {
      enable = true;
      keyboards.default = {
        devices = [
          "/dev/input/by-id/usb-Logitech_Logitech_G710_Keyboard-event-kbd"
          "/dev/input/by-id/usb-Logitech_Logitech_G710_Keyboard-if01-event-kbd"
        ];
        extraDefCfg = "process-unmapped-keys yes";
        config = ''
          (defsrc
              caps
          )
          (defalias
              escctrl (tap-hold-press 1000 1000 esc lctrl)
          )
          (deflayer base
              @escctrl
          )
        '';
      };
    };

    # Enable num lock on login
    home-manager.users.${config.user}.xsession.numlock.enable = true;
  };
}
