{ config, pkgs, lib, ... }:

let

  keybindings =
    config.home-manager.users.${config.user}.programs.sxhkd.keybindings;

  workspaceBindings = let
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

    # Create an attrset of keybinds to actions for every workspace by number
    bindAll = keybindFunction: actionFunction:
      (lib.genAttrs (map keybindFunction (builtins.attrNames workspaces))
        actionFunction);

    # Look up the name of the workspace based on its number
    lookup = num: builtins.getAttr num workspaces;

  in (bindAll (num: "super + ${num}")
    (num: ''${pkgs.i3}/bin/i3-msg "workspace ${lookup num}"''))
  // (bindAll (num: "super + shift + ${num}") (num:
    ''
      ${pkgs.i3}/bin/i3-msg "move container to workspace ${
        lookup num
      }; workspace ${lookup num}"''));

in {

  home-manager.users.${config.user}.programs.sxhkd = {
    enable = true;
    keybindings = {

      # Adjust screen brightness (TODO: replace with pkgs.light?)
      "shift + {F11,F12}" = ''
        ${pkgs.ddcutil}/bin/ddcutil --display 1 setvcp 10 {- 30,+ 30} && sleep 1; \\
        ${pkgs.ddcutil}/bin/ddcutil --display 2 setvcp 10 {- 30,+ 30}
      '';
      "XF86MonBrightness{Down,Up}" = keybindings."shift + {F11,F12}";

      # Media controls
      "XF86Audio{Play,Stop,Next,Prev}" =
        "${pkgs.playerctl}/bin/playerctl {play-pause,stop,next,previous}";

      # Window management
      "super + q" = ''${pkgs.i3}/bin/i3-msg "kill"'';
      "super + b" = config.toggleBarCommand;
      "super + f" = ''${pkgs.i3}/bin/i3-msg "fullscreen toggle"'';
      "super + {h,j,k,l}" =
        ''${pkgs.i3}/bin/i3-msg "focus {left,down,up,right}"'';
      "super + {Left,Down,Up,Right}" = keybindings."super + {h,j,k,l}";
      "super + shift + {h,j,k,l}" =
        ''${pkgs.i3}/bin/i3-msg "move {left,down,up,right}"'';
      "super + shift + {Left,Down,Up,Right}" =
        keybindings."super + shift + {h,j,k,l}";

      # Screen management
      "super + control + l" =
        ''${pkgs.i3}/bin/i3-msg "move workspace to output right"'';
      "super + control + h" =
        ''${pkgs.i3}/bin/i3-msg "move workspace to output left"'';

      # Window layouts and tiling
      "super + {i,v}" = ''${pkgs.i3}/bin/i3-msg "split {h,v}"'';
      "super + {s,t,e}" =
        ''${pkgs.i3}/bin/i3-msg "layout {stacking,tabbed,toggle split}"'';
      "super + shift + space" = ''${pkgs.i3}/bin/i3-msg "floating toggle"'';
      "super + control + space" = ''${pkgs.i3}/bin/i3-msg "focus mode_toggle"'';
      "super + a" = ''${pkgs.i3}/bin/i3-msg "focus parent"'';

      # Launchers
      "super + Return" = config.terminal;
      "super + space" = config.launcherCommand;
      "super + shift + s" = config.systemdSearch;
      "super + shift + a" = config.audioSwitchCommand;
      "alt + Tab" = config.altTabCommand;
      "super + shift + period" = config.powerCommand;
      "super + shift + m" = config.brightnessCommand;
      "super + c" = config.calculatorCommand;
      "super + shift + {c,r}" = ''${pkgs.i3}/bin/i3-msg "{reload,restart}"'';
      "super + shift + x" = config.lockScreenCommand;
      "super + alt + h" =
        "${config.terminal} sh -c '${pkgs.home-manager}/bin/home-manager switch --flake ${config.dotfilesPath}#${config.networking.hostName} || read'";
      "super + alt + r" =
        "${config.terminal} sh -c 'doas nixos-rebuild switch --flake ${config.dotfilesPath}#${config.networking.hostName} || read'";

    } // workspaceBindings;

  };
}
