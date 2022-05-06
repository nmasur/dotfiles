{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.services.xserver.enable {

    services.xserver.windowManager = {
      i3 = {
        enable = true;
        package = pkgs.i3-gaps;
      };
    };

    environment.systemPackages = with pkgs; [
      dmenu # Launcher
      feh # Wallpaper
      playerctl # Media control
    ];

    home-manager.users.${config.user}.xsession.windowManager.i3 = {
      enable = true;
      package = pkgs.i3-gaps;
      config = let
        modifier = "Mod4"; # Super key
        ws1 = "I";
        ws2 = "II";
        ws3 = "III";
        ws4 = "IV";
        ws5 = "V";
        ws6 = "VI";
        ws7 = "VII";
        ws8 = "VIII";
        ws9 = "IX";
        ws10 = "X";
      in {
        modifier = modifier;
        assigns = {
          "${ws1}" = [{ class = "Firefox"; }];
          "${ws2}" = [{ class = "Alacritty"; }];
          "${ws3}" = [{ class = "Discord"; }];
          "${ws4}" = [{ class = "Steam"; }];
        };
        bars = [{ command = "echo"; }]; # Disable i3bar
        colors = let
          background = config.gui.colorscheme.base00;
          inactiveBackground = config.gui.colorscheme.base01;
          border = config.gui.colorscheme.base01;
          inactiveBorder = config.gui.colorscheme.base01;
          text = config.gui.colorscheme.base07;
          inactiveText = config.gui.colorscheme.base04;
          urgentBackground = config.gui.colorscheme.base08;
          indicator = "#00000000";
        in {
          background = config.gui.colorscheme.base00;
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
          mouseWarping = false;
          newWindow = "urgent";
          followMouse = false;
        };
        fonts = {
          names = [ "pango:Victor Mono" "FontAwesome 12" ];
          # style = "Regular";
          # size = 11.0;
        };
        keybindings = {

          # PulseAudio adjust volume
          "XF86AudioRaiseVolume" = "exec --no-startup-id pamixer -i 2";
          "XF86AudioLowerVolume" = "exec --no-startup-id pamixer -d 2";
          "XF86AudioMute" = "exec --no-startup-id pamixer -t";
          "XF86AudioMicMute" =
            "exec --no-startup-id pamixer --default-source -t";

          # Adjust screen brightness
          "Shift+F12" =
            "exec ddcutil --display 1 setvcp 10 + 20; exec ddcutil --display 2 setvcp 10 + 20";
          "Shift+F11" =
            "exec ddcutil --display 1 setvcp 10 - 20; exec ddcutil --display 2 setvcp 10 - 20";
          "XF86MonBrightnessUp" =
            "exec ddcutil --display 1 setvcp 10 + 20; exec ddcutil --display 2 setvcp 10 + 20";
          "XF86MonBrightnessDown" =
            "exec ddcutil --display 1 setvcp 10 - 20; exec ddcutil --display 2 setvcp 10 - 20";

          # Media player controls
          "XF86AudioPlay" = "exec playerctl play-pause";
          "XF86AudioStop" = "exec playerctl stop";
          "XF86AudioNext" = "exec playerctl next";
          "XF86AudioPrev" = "exec playerctl previous";

          # Launchers
          "${modifier}+Return" = "exec alacritty";
          "${modifier}+space" =
            "exec --no-startup-id ${config.gui.launcherCommand}";
          "${modifier}+Shift+c" = "reload";
          "${modifier}+Shift+r" = "restart";
          "${modifier}+Shift+q" = ''
            exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"'';
          "${modifier}+Shift+x" =
            ''exec i3lock --color "${config.gui.colorscheme.base00}"'';
          "${modifier}+Shift+t" = "exec alacritty";

          # Window options
          "${modifier}+q" = "kill";
          "${modifier}+h" = "focus left";
          "${modifier}+j" = "focus down";
          "${modifier}+k" = "focus up";
          "${modifier}+l" = "focus right";
          "${modifier}+Left" = "focus left";
          "${modifier}+Down" = "focus down";
          "${modifier}+Up" = "focus up";
          "${modifier}+Right" = "focus right";
          "${modifier}+Shift+h" = "move left";
          "${modifier}+Shift+j" = "move down";
          "${modifier}+Shift+k" = "move up";
          "${modifier}+Shift+l" = "move right";
          "${modifier}+Shift+Left" = "move left";
          "${modifier}+Shift+Down" = "move down";
          "${modifier}+Shift+Up" = "move up";
          "${modifier}+Shift+Right" = "move right";

          # Tiling
          "${modifier}+i" = "split h";
          "${modifier}+v" = "split v";
          "${modifier}+s" = "layout stacking";
          "${modifier}+t" = "layout tabbed";
          "${modifier}+e" = "layout toggle split";
          "${modifier}+Shift+space" = "floating toggle";
          "${modifier}+Control+space" = "focus mode_toggle";
          "${modifier}+a" = "focus parent";

          # Workspaces
          "${modifier}+1" = "workspace ${ws1}";
          "${modifier}+2" = "workspace ${ws2}";
          "${modifier}+3" = "workspace ${ws3}";
          "${modifier}+4" = "workspace ${ws4}";
          "${modifier}+5" = "workspace ${ws5}";
          "${modifier}+6" = "workspace ${ws6}";
          "${modifier}+7" = "workspace ${ws7}";
          "${modifier}+8" = "workspace ${ws8}";
          "${modifier}+9" = "workspace ${ws9}";
          "${modifier}+0" = "workspace ${ws10}";

          # Move windows
          "${modifier}+Shift+1" = "move container to workspace ${ws1}";
          "${modifier}+Shift+2" = "move container to workspace ${ws2}";
          "${modifier}+Shift+3" = "move container to workspace ${ws3}";
          "${modifier}+Shift+4" = "move container to workspace ${ws4}";
          "${modifier}+Shift+5" = "move container to workspace ${ws5}";
          "${modifier}+Shift+6" = "move container to workspace ${ws6}";
          "${modifier}+Shift+7" = "move container to workspace ${ws7}";
          "${modifier}+Shift+8" = "move container to workspace ${ws8}";
          "${modifier}+Shift+9" = "move container to workspace ${ws9}";
          "${modifier}+Shift+0" = "move container to workspace ${ws10}";

          # Move screens
          "${modifier}+Control+l" = "move workspace to output right";
          "${modifier}+Control+h" = "move workspace to output left";

          # Resizing
          "${modifier}+r" = ''mode "resize"'';
        };
        modes = {
          resize = {
            h = "resize shrink width 10 px or 10 ppt";
            j = "resize grow height 10 px or 10 ppt";
            k = "resize shrink height 10 px or 10 ppt";
            l = "resize grow width 10 px or 10 ppt";
            Left = "resize shrink width 10 px or 10 ppt";
            Down = "resize grow height 10 px or 10 ppt";
            Up = "resize shrink height 10 px or 10 ppt";
            Right = "resize grow width 10 px or 10 ppt";
            Return = ''mode "default"'';
            Caps_Lock = ''mode "default"'';
            "${modifier}+r" = ''mode "default"'';
          };
        };
        startup = [
          {
            command = "feh --bg-fill ${builtins.toString config.gui.wallpaper}";
            always = true;
            notification = false;
          }
          {
            # xss-lock grabs a logind suspend inhibit lock and will use i3lock to lock the
            # screen before suspend. Use loginctl lock-session to lock your screen.
            command = "xss-lock --transfer-sleep-lock -- i3lock --nofork";
            always = false;
            notification = false;
          }
        ];
        window = {
          border = 0;
          hideEdgeBorders = "smart";
          titlebar = false;
        };
        workspaceAutoBackAndForth = false;
        workspaceOutputAssign = [ ];
        # gaps = {
        # bottom = 8;
        # top = 8;
        # left = 8;
        # right = 8;
        # horizontal = 15;
        # vertical = 15;
        # inner = 15;
        # outer = 0;
        # smartBorders = "off";
        # smartGaps = false;
        # };
      };
      extraConfig = "";
    };

  };

}
