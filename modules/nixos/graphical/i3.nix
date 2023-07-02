{ config, pkgs, lib, ... }:

let

  lockUpdate =
    "${pkgs.betterlockscreen}/bin/betterlockscreen --update ${config.wallpaper} --display 1 --span";

in {

  config = lib.mkIf pkgs.stdenv.isLinux {

    services.xserver.windowManager = {
      i3 = { enable = config.services.xserver.enable; };
    };

    environment.systemPackages = with pkgs; [
      feh # Wallpaper
      playerctl # Media control
    ];

    home-manager.users.${config.user} = {
      xsession.windowManager.i3 = {
        enable = config.services.xserver.enable;
        config = let
          modifier = "Mod4"; # Super key
          ws1 = "1:I";
          ws2 = "2:II";
          ws3 = "3:III";
          ws4 = "4:IV";
        in {
          modifier = modifier;
          assigns = {
            "${ws1}" = [{ class = "Firefox"; }];
            "${ws2}" = [
              { class = "kitty"; }
              { class = "aerc"; }
              { class = "obsidian"; }
            ];
            "${ws3}" = [{ class = "discord"; }];
            "${ws4}" = [{ class = "Steam"; }];
          };
          bars = [{ command = "echo"; }]; # Disable i3bar
          colors = let
            background = config.theme.colors.base00;
            inactiveBackground = config.theme.colors.base01;
            border = config.theme.colors.base01;
            inactiveBorder = config.theme.colors.base01;
            text = config.theme.colors.base07;
            inactiveText = config.theme.colors.base04;
            urgentBackground = config.theme.colors.base08;
            indicator = "#00000000";
          in {
            background = config.theme.colors.base00;
            focused = {
              inherit background indicator text border;
              childBorder = background;
            };
            focusedInactive = {
              inherit indicator;
              background = inactiveBackground;
              border = inactiveBorder;
              childBorder = inactiveBackground;
              text = inactiveText;
            };
            # placeholder = { };
            unfocused = {
              inherit indicator;
              background = inactiveBackground;
              border = inactiveBorder;
              childBorder = inactiveBackground;
              text = inactiveText;
            };
            urgent = {
              inherit text indicator;
              background = urgentBackground;
              border = urgentBackground;
              childBorder = urgentBackground;
            };
          };
          floating.modifier = modifier;
          focus = {
            mouseWarping = true;
            newWindow = "urgent";
            followMouse = false;
          };
          keybindings = {
            # Resizing
            "${modifier}+r" = ''mode "resize"'';
            "${modifier}+Control+Shift+h" =
              "resize shrink width 10 px or 10 ppt";
            "${modifier}+Control+Shift+j" =
              "resize grow height 10 px or 10 ppt";
            "${modifier}+Control+Shift+k" =
              "resize shrink height 10 px or 10 ppt";
            "${modifier}+Control+Shift+l" = "resize grow width 10 px or 10 ppt";
          };
          modes = { };
          startup = [
            {
              command = "feh --bg-fill ${config.wallpaper}";
              always = true;
              notification = false;
            }
            {
              command =
                "i3-msg workspace ${ws2}, move workspace to output right";
              notification = false;
            }
            {
              command =
                "i3-msg workspace ${ws1}, move workspace to output left";
              notification = false;
            }
          ];
          terminal = config.terminal;
          window = {
            border = 0;
            hideEdgeBorders = "smart";
            titlebar = false;
          };
          workspaceAutoBackAndForth = false;
          workspaceOutputAssign = [ ];
        };
        extraConfig = "";
      };

      lockScreenCommand =
        "${pkgs.betterlockscreen}/bin/betterlockscreen --lock --display 1 --blur 0.5 --span";

      programs.fish.functions = {
        update-lock-screen = lib.mkIf config.services.xserver.enable {
          description = "Update lockscreen with wallpaper";
          body = lockUpdate;
        };
      };

      # Update lock screen cache only if cache is empty
      home.activation.updateLockScreenCache =
        let cacheDir = "${config.homePath}/.cache/betterlockscreen/current";
        in lib.mkIf config.services.xserver.enable
        (config.home-manager.users.${config.user}.lib.dag.entryAfter
          [ "writeBoundary" ] ''
            if [ ! -d ${cacheDir} ] || [ -z "$(ls ${cacheDir})" ]; then
                $DRY_RUN_CMD ${lockUpdate}
            fi
          '');

    };

    # Ref: https://github.com/betterlockscreen/betterlockscreen/blob/next/system/betterlockscreen%40.service
    systemd.services.lock = {
      enable = config.services.xserver.enable;
      description = "Lock the screen before suspend";
      before = [ "sleep.target" "suspend.target" ];
      serviceConfig = {
        User = config.user;
        Type = "simple";
        Environment = "DISPLAY=:0";
        TimeoutSec = "infinity";
        ExecStart = config.lockScreenCommand;
        ExecStartPost = "${pkgs.coreutils-full}/bin/sleep 1";
      };
      wantedBy = [ "sleep.target" "suspend.target" ];
    };

  };

}
