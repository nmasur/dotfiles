{ config, pkgs, ... }:

let

  binds = config.home-manager.users.${config.user}.programs.sxhkd.keybindings;

in {

  home-manager.users.${config.user}.programs.sxhkd = {
    enable = true;
    keybindings = {

      # Adjust screen brightness (TODO: replace with pkgs.light?)
      "shift + {F11,F12}" = ''
        ${pkgs.ddcutil}/bin/ddcutil --display 1 setvcp 10 {- 30,+ 30} && sleep 1; \\
        ${pkgs.ddcutil}/bin/ddcutil --display 2 setvcp 10 {- 30,+ 30}
      '';
      "XF86MonBrightness{Down,Up}" = binds."shift + {F11,F12}";

      # Media controls
      "XF86Audio{Play,Stop,Next,Prev}" =
        "${pkgs.playerctl}/bin/playerctl {play-pause,stop,next,previous}";

      # Toggle bar
      "super + b" = config.toggleBarCommand;

      # Launchers
      "super + Return" = config.terminal;
      "super + space" = config.launcherCommand;
      "super + shift + s" = config.systemdSearch;
      "super + shift + a" = config.audioSwitchCommand;
      "alt + Tab" = config.altTabCommand;
      "super + shift + period" = config.powerCommand;
      "super + shift + m" = config.brightnessCommand;
      "super + c" = config.calculatorCommand;
      "super + shift + x" = config.lockScreenCommand;
      "super + alt + h" =
        "${config.terminal} sh -c '${pkgs.home-manager}/bin/home-manager switch --flake ${config.dotfilesPath}#${config.networking.hostName} || read'";
      "super + alt + r" =
        "${config.terminal} sh -c 'doas nixos-rebuild switch --flake ${config.dotfilesPath}#${config.networking.hostName} || read'";

    };

  };
}
