{ config, pkgs, lib, ... }:

let

  lockUpdate =
    "${pkgs.betterlockscreen}/bin/betterlockscreen --update ${config.wallpaper} --display 1 --span";

  workspaces = {
    "1" = "1:I";
    "2" = "2:II";
    "3" = "3:III";
    "4" = "4:IV";
    "5" = "5:V";
    "6" = "6:VI";
    "7" = "7:VII";
    "8" = "8:VIII";
    "9" = "9:IX";
    "0" = "10:X";
  };

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
        config = let modifier = "Mod4"; # Super key
        in {
          modifier = modifier;
          assigns = {
            "${workspaces."1"}" = [{ class = "Firefox"; }];
            "${workspaces."2"}" = [
              { class = "kitty"; }
              { class = "aerc"; }
              { class = "obsidian"; }
            ];
            "${workspaces."3"}" = [{ class = "discord"; }];
            "${workspaces."4"}" = [{ class = "Steam"; }];
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
          keybindings = { };
          modes = { };
          startup = [
            {
              command = "feh --bg-fill ${config.wallpaper}";
              always = true;
              notification = false;
            }
            {
              command = "i3-msg workspace ${
                  workspaces."1"
                }, move workspace to output right";
              notification = false;
            }
            {
              command = "i3-msg workspace ${
                  workspaces."2"
                }, move workspace to output left";
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

      programs.sxhkd.keybindings = let

        # Shortcuts
        binds =
          config.home-manager.users.${config.user}.programs.sxhkd.keybindings;
        i3-msg = "${pkgs.i3}/bin/i3-msg";

        # Create an attrset of keybinds to actions for every workspace by number
        bindAll = let workspaceNums = builtins.attrNames workspaces;
        in keybindFunction: actionFunction:
        # 1 -> "keybind + 1" -> "some action on ws 1"
        lib.genAttrs (map keybindFunction workspaceNums) actionFunction;

        # Look up the name of the workspace based on its number
        lookup = num: builtins.getAttr num workspaces;

      in {

        # Window navigation
        "super + {h,j,k,l}" = ''${i3-msg} "focus {left,down,up,right}"'';
        "super + {Left,Down,Up,Right}" = binds."super + {h,j,k,l}";
        "super + shift + {h,j,k,l}" = ''${i3-msg} "move {left,down,up,right}"'';
        "super + shift + {Left,Down,Up,Right}" =
          binds."super + shift + {h,j,k,l}";
        "super + q" = ''${i3-msg} "kill"'';
        "super + f" = ''${i3-msg} "fullscreen toggle"'';

        # Screen management
        "super + control + l" = ''${i3-msg} "move workspace to output right"'';
        "super + control + h" = ''${i3-msg} "move workspace to output left"'';

        # Window layouts and tiling
        "super + {i,v}" = ''${i3-msg} "split {h,v}"'';
        "super + {s,t,e}" =
          ''${i3-msg} "layout {stacking,tabbed,toggle split}"'';
        "super + shift + space" = ''${i3-msg} "floating toggle"'';
        "super + control + space" = ''${i3-msg} "focus mode_toggle"'';
        "super + a" = ''${i3-msg} "focus parent"'';

        # Restart and reload
        "super + shift + {c,r}" = ''${i3-msg} "{reload,restart}"'';

      }

      # Bind super + workspace -> switch to workspace
      // (bindAll (num: "super + ${num}")
        (num: ''${i3-msg} "workspace ${lookup num}"''))

      # Bind super + shift + workspace -> move to workspace
      // (bindAll (num: "super + shift + ${num}") (num:
        ''
          ${i3-msg} "move container to workspace ${lookup num}; workspace ${
            lookup num
          }"''));

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
