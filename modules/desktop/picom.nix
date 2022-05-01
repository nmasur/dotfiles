{ config, lib, identity, ... }: {

  config = lib.mkIf config.services.xserver.enable {
    home-manager.users.${identity.user} = {

      services.picom = {
        enable = true;
        blur = false;
        blurExclude = [ ];
        extraOptions = ''
          shadow-radius = 60
          corner-radius = 20
        '';
        fade = false;
        experimentalBackends = true;
        inactiveDim = "0.2";
        inactiveOpacity = "1.0";
        menuOpacity = "1.0";
        noDNDShadow = false;
        opacityRule = [
          "0:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_HIDDEN'" # Hide tabbed windows
        ];
        shadow = true;
        shadowExclude = [ ];
        shadowOffsets = [ (-30) (-30) ];
        shadowOpacity = "0.25";
        vSync = false;
      };

      xsession.windowManager.i3.config.startup = [{
        command = "systemctl --user restart picom";
        always = true;
        notification = false;
      }];

    };
  };

}
