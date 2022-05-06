{ config, lib, ... }: {

  config =
    lib.mkIf (config.services.xserver.enable && config.gui.compositor.enable) {
      home-manager.users.${config.user} = {

        services.picom = {
          enable = true;
          blur = true;
          blurExclude = [ ];
          # extraOptions = ''
          # shadow-radius = 20
          # '';
          extraOptions = ''
            shadow-radius = 20
            corner-radius = 10
            blur-size = 20
            rounded-corners-exclude = [ 
              "window_type = 'dock'",
              "class_g = 'i3-frame'"
            ]
          '';
          fade = false;
          experimentalBackends = true;
          inactiveDim = "0.05";
          inactiveOpacity = "1.0";
          menuOpacity = "1.0";
          noDNDShadow = false;
          noDockShadow = false;
          opacityRule = [
            "0:_NET_WM_STATE@[0]:32a = '_NET_WM_STATE_HIDDEN'" # Hide tabbed windows
          ];
          shadow = true;
          shadowExclude = [ ];
          shadowOffsets = [ (-10) (-10) ];
          shadowOpacity = "0.5";
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
