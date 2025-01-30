{ config, pkgs, ... }:
let

  rofi = config.home-manager.users.${config.user}.programs.rofi.finalPackage;
in
{

  # Adapted from:
  # A rofi powered menu to execute brightness choices.

  config.brightnessCommand = builtins.toString (
    pkgs.writeShellScript "brightness" ''

      dimmer="󰃝"
      medium="󰃟"
      brighter="󰃠"

      chosen=$(printf '%s;%s;%s\n' \
          "$dimmer" \
          "$medium" \
          "$brighter" \
          | ${rofi}/bin/rofi \
              -theme-str '@import "brightness.rasi"' \
              -hover-select \
              -me-select-entry ''' \
              -me-accept-entry MousePrimary \
              -dmenu \
              -sep ';' \
              -selected-row 1)


      case "$chosen" in
          "$dimmer")
              ${pkgs.ddcutil}/bin/ddcutil --display 1 setvcp 10 25; ${pkgs.ddcutil}/bin/ddcutil --disable-dynamic-sleep --display 2 setvcp 10 25
              ;;

          "$medium")
              ${pkgs.ddcutil}/bin/ddcutil --display 1 setvcp 10 75; ${pkgs.ddcutil}/bin/ddcutil --disable-dynamic-sleep --display 2 setvcp 10 75
              ;;

          "$brighter")
              ${pkgs.ddcutil}/bin/ddcutil --display 1 setvcp 10 100; ${pkgs.ddcutil}/bin/ddcutil --disable-dynamic-sleep --display 2 setvcp 10 100
              ;;

          *) exit 1 ;;
      esac

    ''
  );
}
