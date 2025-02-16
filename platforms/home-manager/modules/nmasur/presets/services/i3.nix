{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.i3;
in

{

  options.nmasur.presets.services.i3 = {
    enable = lib.mkEnableOption "i3 window manager";
    terminal = lib.mkOption {
      type = lib.types.package;
      description = "Terminal application to launch";
    };
    wallpaper = {
      type = lib.types.path;
      description = "Wallpaper background image file";
      default = "${pkgs.wallpapers}/gruvbox/road.jpg";
    };
    commands = {
      launcher = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Application launcher";
        default = null;
      };
      lockScreen = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Screen lock";
        default = "${lib.getExe pkgs.betterlockscreen} --lock --display 1 --blur 0.5 --span";
      };
      updateLockScreen = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Update lock screen cache";
        default = "${lib.getExe pkgs.betterlockscreen} --update ${cfg.wallpaper} --display 1 --span";
      };
      toggleBar = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Toggle menu bar panel";
        default = null;
      };
      systemdSearch = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Search systemd";
        default = null;
      };
      audioSwitch = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Switch audio output";
        default = null;
      };
      applicationSwitch = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Application switcher";
        default = null;
      };
      power = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Launch power options menu";
        default = null;
      };
      brightness = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Launch brightness adjuster";
        default = null;
      };
      calculator = lib.mkOption {
        type = lib.types.nullOr lib.types.str;
        description = "Launch calculator";
        default = null;
      };
    };
  };

  config = lib.mkIf cfg.enable {
    xsession.windowManager.i3 = {
      enable = config.services.xserver.enable;
      config =
        let
          modifier = "Mod4"; # Super key
          ws1 = "1:I";
          ws2 = "2:II";
          ws3 = "3:III";
          ws4 = "4:IV";
          ws5 = "5:V";
          ws6 = "6:VI";
          ws7 = "7:VII";
          ws8 = "8:VIII";
          ws9 = "9:IX";
          ws10 = "10:X";
        in
        {
          terminal = cfg.terminal.meta.mainProgram;
          modifier = modifier;
          assigns = {
            "${ws1}" = [ { class = "Firefox"; } ];
            "${ws2}" = [
              { class = "aerc"; }
              { class = "kitty"; }
              { class = "obsidian"; }
              { class = "wezterm"; }
            ];
            "${ws3}" = [ { class = "discord"; } ];
            "${ws4}" = [
              { class = "steam"; }
              { class = "Steam"; }
            ];
          };
          bars = [ { command = "echo"; } ]; # Disable i3bar
          colors =
            let
              background = config.theme.colors.base00;
              inactiveBackground = config.theme.colors.base01;
              border = config.theme.colors.base01;
              inactiveBorder = config.theme.colors.base01;
              text = config.theme.colors.base07;
              inactiveText = config.theme.colors.base04;
              urgentBackground = config.theme.colors.base08;
              indicator = "#00000000";
            in
            {
              background = config.theme.colors.base00;
              focused = {
                inherit
                  background
                  indicator
                  text
                  border
                  ;
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

            # Adjust screen brightness
            "Shift+F12" =
              # Disable dynamic sleep
              # https://github.com/rockowitz/ddcutil/issues/323
              "exec ${lib.getExe pkgs.ddcutil} --display 1 setvcp 10 + 30 && sleep 1; exec ${pkgs.ddcutil}/bin/ddcutil --disable-dynamic-sleep --display 2 setvcp 10 + 30";
            "Shift+F11" =
              "exec ${lib.getExe pkgs.ddcutil} --display 1 setvcp 10 - 30 && sleep 1; exec ${pkgs.ddcutil}/bin/ddcutil --disable-dynamic-sleep --display 2 setvcp 10 - 30";
            "XF86MonBrightnessUp" =
              "exec ${lib.getExe pkgs.ddcutil} --display 1 setvcp 10 + 30 && sleep 1; exec ${pkgs.ddcutil}/bin/ddcutil --disable-dynamic-sleep --display 2 setvcp 10 + 30";
            "XF86MonBrightnessDown" =
              "exec ${lib.getExe pkgs.ddcutil} --display 1 setvcp 10 - 30 && sleep 1; exec ${pkgs.ddcutil}/bin/ddcutil --disable-dynamic-sleep --display 2 setvcp 10 - 30";

            # Media player controls
            "XF86AudioPlay" = "exec ${lib.getExe pkgs.playerctl} play-pause";
            "XF86AudioStop" = "exec ${lib.getExe pkgs.playerctl} stop";
            "XF86AudioNext" = "exec ${lib.getExe pkgs.playerctl} next";
            "XF86AudioPrev" = "exec ${lib.getExe pkgs.playerctl} previous";

            # Launchers
            "${modifier}+Return" =
              "exec --no-startup-id ${lib.getExe cfg.terminal}; workspace ${ws2}; layout tabbed";
            "${modifier}+space" =
              lib.mkIf cfg.commands.launcher != null "exec --no-startup-id ${cfg.commands.launcher}";
            "${modifier}+Shift+s" =
              lib.mkIf cfg.commands.systemdSearch != null "exec --no-startup-id ${cfg.commands.systemdSearch}";
            "${modifier}+Shift+a" =
              lib.mkIf cfg.commands.audioSwitch != null "exec --no-startup-id ${cfg.commands.audioSwitch}";
            "Mod1+Tab" = lib.mkIf cfg.commands.altTab != null "exec --no-startup-id ${cfg.commands.altTab}";
            "${modifier}+Shift+period" =
              lib.mkIf cfg.commands.power != null "exec --no-startup-id ${cfg.commands.power}";
            "${modifier}+Shift+m" =
              lib.mkIf cfg.commands.brightness != null "exec --no-startup-id ${cfg.commands.brightness}";
            "${modifier}+c" =
              lib.mkIf cfg.commands.calculator != null "exec --no-startup-id ${cfg.commands.calculator}";
            "${modifier}+Shift+c" = "reload";
            "${modifier}+Shift+r" = "restart";
            "${modifier}+Shift+q" =
              ''exec "i3-nagbar -t warning -m 'You pressed the exit shortcut. Do you really want to exit i3? This will end your X session.' -B 'Yes, exit i3' 'i3-msg exit'"'';
            "${modifier}+Shift+x" = lib.mkIf cfg.commands.lockScreen != null "exec ${cfg.commands.lockScreen}";
            "${modifier}+Mod1+h" =
              "exec --no-startup-id ${lib.getExe cfg.terminal} -e sh -c '${pkgs.home-manager}/bin/home-manager switch --flake ${config.nmasur.presets.programs.dotfiles.path}#${config.networking.hostName} || read'";
            "${modifier}+Mod1+r" =
              "exec --no-startup-id ${lib.getExe cfg.terminal} -e sh -c 'doas nixos-rebuild switch --flake ${config.nmasur.presets.programs.dotfiles.path}#${config.networking.hostName} || read'";

            # Window options
            "${modifier}+q" = "kill";
            "${modifier}+b" = lib.mkIf cfg.commands.toggleBar "exec ${cfg.commands.toggleBar}";
            "${modifier}+f" = "fullscreen toggle";
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
            "${modifier}+Shift+1" = "move container to workspace ${ws1}; workspace ${ws1}";
            "${modifier}+Shift+2" = "move container to workspace ${ws2}; workspace ${ws2}";
            "${modifier}+Shift+3" = "move container to workspace ${ws3}; workspace ${ws3}";
            "${modifier}+Shift+4" = "move container to workspace ${ws4}; workspace ${ws4}";
            "${modifier}+Shift+5" = "move container to workspace ${ws5}; workspace ${ws5}";
            "${modifier}+Shift+6" = "move container to workspace ${ws6}; workspace ${ws6}";
            "${modifier}+Shift+7" = "move container to workspace ${ws7}; workspace ${ws7}";
            "${modifier}+Shift+8" = "move container to workspace ${ws8}; workspace ${ws8}";
            "${modifier}+Shift+9" = "move container to workspace ${ws9}; workspace ${ws9}";
            "${modifier}+Shift+0" = "move container to workspace ${ws10}; workspace ${ws10}";

            # Move screens
            "${modifier}+Control+l" = "move workspace to output right";
            "${modifier}+Control+h" = "move workspace to output left";

            # Resizing
            "${modifier}+r" = ''mode "resize"'';
            "${modifier}+Control+Shift+h" = "resize shrink width 10 px or 10 ppt";
            "${modifier}+Control+Shift+j" = "resize grow height 10 px or 10 ppt";
            "${modifier}+Control+Shift+k" = "resize shrink height 10 px or 10 ppt";
            "${modifier}+Control+Shift+l" = "resize grow width 10 px or 10 ppt";
          };
          modes = { };
          startup = [
            {
              command = "feh --bg-fill ${cfg.wallpaper}";
              always = true;
              notification = false;
            }
            {
              command = "i3-msg workspace ${ws2}, move workspace to output right";
              notification = false;
            }
            {
              command = "i3-msg workspace ${ws1}, move workspace to output left";
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

    programs.fish.functions = {
      update-lock-screen =
        lib.mkIf cfg.commands.updateLockScreen != null {
          description = "Update lockscreen with wallpaper";
          body = cfg.commands.updateLockScreen;
        };
    };

    # Update lock screen cache only if cache is empty
    home.activation.updateLockScreenCache =
      let
        cacheDir = "${config.xdg.cacheHome}/betterlockscreen/current";
      in
      lib.mkIf cfg.commands.updateLockScreen != null (
        config.lib.dag.entryAfter [ "writeBoundary" ] ''
          if [ ! -d ${cacheDir} ] || [ -z "$(ls ${cacheDir})" ]; then
              run ${cfg.commands.updateLockScreen}
          fi
        ''
      );

  };
}
