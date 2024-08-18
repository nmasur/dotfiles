{
  config,
  pkgs,
  lib,
  ...
}:
{

  config = lib.mkIf (pkgs.stdenv.isLinux && config.services.xserver.enable) {

    toggleBarCommand = "polybar-msg cmd toggle";

    home-manager.users.${config.user} = {

      services.polybar = {
        enable = true;
        package = pkgs.polybar.override {
          pulseSupport = true;
          githubSupport = true;
          i3Support = true;
        };
        script = "polybar &";
        config = {
          "bar/main" = {
            bottom = false;
            width = "100%";
            height = "22pt";
            radius = 0;
            # offset-y = -5;
            # offset-y = "5%";
            # dpi = 96;
            background = config.theme.colors.base01;
            foreground = config.theme.colors.base05;
            line-size = "3pt";
            border-top-size = 0;
            border-right-size = 0;
            border-left-size = 0;
            border-bottom-size = "4pt";
            border-color = config.theme.colors.base00;
            padding-left = 2;
            padding-right = 2;
            module-margin = 1;
            modules-left = "i3";
            modules-center = "xwindow";
            modules-right = "mailcount network pulseaudio date power";
            cursor-click = "pointer";
            cursor-scroll = "ns-resize";
            enable-ipc = true;
            tray-position = "right";
            # wm-restack = "generic";
            # wm-restack = "bspwm";
            # wm-restack = "i3";
            # override-redirect = true;
          };
          "module/i3" =
            let
              padding = 2;
            in
            {
              type = "internal/i3";
              pin-workspaces = false;
              show-urgent = true;
              strip-wsnumbers = true;
              index-sort = true;
              enable-click = true;
              wrapping-scroll = true;
              fuzzy-match = true;
              format = "<label-state> <label-mode>";
              label-focused = "%name%";
              label-focused-foreground = config.theme.colors.base01;
              label-focused-background = config.theme.colors.base05;
              label-focused-underline = config.theme.colors.base03;
              label-focused-padding = padding;
              label-unfocused = "%name%";
              label-unfocused-padding = padding;
              label-visible = "%name%";
              label-visible-underline = config.theme.colors.base01;
              label-visible-padding = padding;
              label-urgent = "%name%";
              label-urgent-foreground = config.theme.colors.base00;
              label-urgent-background = config.theme.colors.base08;
              label-urgent-underline = config.theme.colors.base0F;
              label-urgent-padding = padding;
            };
          "module/xworkspaces" = {
            type = "internal/xworkspaces";
            label-active = "%name%";
            label-active-background = config.theme.colors.base05;
            label-active-foreground = config.theme.colors.base01;
            label-active-underline = config.theme.colors.base03;
            label-active-padding = 1;
            label-occupied = "%name%";
            label-occupied-padding = 1;
            label-urgent = "%name%";
            label-urgent-background = config.theme.colors.base08;
            label-urgent-padding = 1;
            label-empty = "%name%";
            label-empty-foreground = config.theme.colors.base06;
            label-empty-padding = 1;
          };
          "module/xwindow" = {
            type = "internal/xwindow";
            label = "%title:0:60:...%";
          };
          # "module/filesystem" = {
          # type = "internal/fs";
          # interval = 25;
          # mount-0 = "/";
          # label-mounted = "%{F#F0C674}%mountpoint%%{F-} %percentage_used%%";
          # label-unmounted = "%mountpoint% not mounted";
          # label-unmounted-foreground = colors.disabled;
          # };
          "module/mailcount" = {
            type = "custom/script";
            interval = 10;
            format = "<label>";
            exec = builtins.toString (
              pkgs.writeShellScript "mailcount.sh" ''
                ${pkgs.notmuch}/bin/notmuch new --quiet 2>&1>/dev/null
                UNREAD=$(
                    ${pkgs.notmuch}/bin/notmuch count \
                        is:inbox and \
                        is:unread and \
                        folder:main/Inbox \
                        2>/dev/null
                )
                if [ $UNREAD = "0" ]; then
                  echo ""
                else
                  echo "%{T2}%{T-} $UNREAD "
                fi
              ''
            );
            click-left = "i3-msg 'exec --no-startup-id kitty --class aerc aerc'; sleep 0.15; i3-msg '[class=aerc] focus'";
          };
          "module/network" = {
            type = "internal/network";
            interface-type = "wired";
            interval = 3;
            accumulate-stats = true;
            format-connected = "<label-connected>";
            format-disconnected = "<label-disconnected>";
            label-connected = "";
            label-disconnected = "";
          };
          "module/pulseaudio" = {
            type = "internal/pulseaudio";
            # format-volume-prefix = "VOL ";
            # format-volume-prefix-foreground = colors.primary;
            format-volume = "<ramp-volume> <label-volume>";
            # format-volume-background = colors.background;
            # label-volume-background = colors.background;
            format-volume-foreground = config.theme.colors.base04;
            label-volume = "%percentage%%";
            label-muted = "󰝟 ---";
            label-muted-foreground = config.theme.colors.base03;
            ramp-volume-0 = "";
            ramp-volume-1 = "󰕾";
            ramp-volume-2 = "";
            click-right = config.audioSwitchCommand;
          };
          # "module/xkeyboard" = {
          # type = "internal/xkeyboard";
          # blacklist-0 = "num lock";
          # label-layout = "%layout%";
          # label-layout-foreground = colors.primary;
          # label-indicator-padding = 2;
          # label-indicator-margin = 1;
          # label-indicator-foreground = colors.background;
          # label-indicator-background = colors.secondary;
          # };
          # "module/memory" = {
          # type = "internal/memory";
          # interval = 2;
          # format-prefix = "RAM ";
          # format-prefix-foreground = colors.primary;
          # label = "%percentage_used:2%%";
          # };
          # "module/cpu" = {
          # type = "internal/cpu";
          # interval = 2;
          # format-prefix = "CPU ";
          # format-prefix-foreground = colors.primary;
          # label = "%percentage:2%%";
          # };
          # "network-base" = {
          # type = "internal/network";
          # interval = 5;
          # format-connected = "<label-connected>";
          # format-disconnected = "<label-disconnected>";
          # label-disconnected = "%{F#F0C674}%ifname%%{F#707880} disconnected";
          # };
          # "module/wlan" = {
          # "inherit" = "network-base";
          # interface-type = "wireless";
          # label-connected = "%{F#F0C674}%ifname%%{F-} %essid% %local_ip%";
          # };
          # "module/eth" = {
          # "inherit" = "network-base";
          # interface-type = "wired";
          # label-connected = "%{F#F0C674}%ifname%%{F-} %local_ip%";
          # };
          "module/date" = {
            type = "internal/date";
            interval = 1;
            date = "%d %b %l:%M %p";
            date-alt = "%Y-%m-%d %H:%M:%S";
            label = "%date%";
            label-foreground = config.theme.colors.base06;
            # format-background = colors.background;
          };
          "module/power" = {
            type = "custom/text";
            content = "  ";
            click-left = config.powerCommand;
            click-right = "polybar-msg cmd restart";
            content-foreground = config.theme.colors.base04;
          };
          "settings" = {
            screenchange-reload = true;
            pseudo-transparency = false;
          };
        };
      };

      xsession.windowManager.i3.config.startup = [
        {
          command = "pkill polybar; polybar -r main";
          always = true;
          notification = false;
        }
      ];
    };
  };
}
