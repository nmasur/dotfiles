{ config, pkgs, lib, identity, ... }: {

  config = lib.mkIf config.services.xserver.enable {

    # Used for icons
    fonts.fonts = with pkgs;
      [ (nerdfonts.override { fonts = [ "JetBrainsMono" ]; }) ];

    home-manager.users.${identity.user} = {

      services.polybar = {
        enable = true;
        package = pkgs.polybar.override {
          i3GapsSupport = true;
          pulseSupport = true;
          githubSupport = true;
        };
        script = "polybar &";
        config = let
          colors = {
            background = "#282828";
            background-alt = "#373B41";
            foreground = "#C5C8C6";
            primary = "#F0C674";
            secondary = "#8ABEB7";
            alert = "#A54242";
            disabled = "#707880";
          };
        in {
          "bar/main" = {
            bottom = false;
            width = "100%";
            height = "22pt";
            radius = 0;
            # offset-y = "5%";
            # dpi = 96;
            background = colors.background;
            foreground = colors.foreground;
            line-size = "3pt";
            border-top-size = 0;
            border-right-size = 0;
            border-left-size = 0;
            border-bottom-size = "4pt";
            border-color = "#1d2021";
            padding-left = 2;
            padding-right = 2;
            module-margin = 1;
            # separator = "|";
            # separator-foreground = colors.disabled;
            font-0 = "JetBrainsMono Nerd Font:size=10;2";
            # font-0 = "monospace;2";
            # font-1 = "Font Awesome 5 Free:size=10";
            # font-2 = "Font Awesome 5 Free Solid:size=10";
            # font-3 = "Font Awesome 5 Brands:size=10";
            modules-left = "xworkspaces";
            modules-center = "xwindow";
            modules-right = "pulseaudio date";
            cursor-click = "pointer";
            cursor-scroll = "ns-resize";
            enable-ipc = true;
            tray-position = "right";
            # wm-restack = "generic";
            # wm-restack = "bspwm";
            # wm-restack = "i3";
            # override-redirect = true;
          };
          "module/xworkspaces" = {
            type = "internal/xworkspaces";
            label-active = "%name%";
            label-active-background = colors.background-alt;
            label-active-underline = colors.primary;
            label-active-padding = 1;
            label-occupied = "%name%";
            label-occupied-padding = 1;
            label-urgent = "%name%";
            label-urgent-background = colors.alert;
            label-urgent-padding = 1;
            label-empty = "%name%";
            label-empty-foreground = colors.disabled;
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
          "module/pulseaudio" = {
            type = "internal/pulseaudio";
            # format-volume-prefix = "VOL ";
            # format-volume-prefix-foreground = colors.primary;
            format-volume = "<ramp-volume> <label-volume>";
            label-volume = "%percentage%%";
            label-muted = "ﱝ ---";
            label-muted-foreground = colors.disabled;
            ramp-volume-0 = "";
            ramp-volume-1 = "墳";
            ramp-volume-2 = "";
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
            date = "%H:%M";
            date-alt = "%Y-%m-%d %H:%M:%S";
            label = " %date%";
            label-foreground = colors.primary;
          };
          "settings" = {
            screenchange-reload = true;
            pseudo-transparency = false;
          };
        };
      };

      xsession.windowManager.i3.config.startup = [{
        command = "systemctl --user restart polybar";
        always = true;
        notification = false;
      }];

    };
  };

}

