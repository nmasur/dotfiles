{
  config,
  pkgs,
  lib,
  ...
}:
let

  rofi = config.programs.rofi.finalPackage;
in
{

  # Adapted from:
  # A rofi powered menu to execute brightness choices.

  config.nmasur.presets.services.i3.commands.brightness =
    lib.mkIf config.nmasur.presets.programs.rofi.enable
      (
        builtins.toString (
          pkgs.writeShellScript "brightness" # bash
            ''

              dimmer="󰃝"
              medium="󰃟"
              brighter="󰃠"

              chosen=$(printf '%s;%s;%s\n' \
                  "$dimmer" \
                  "$medium" \
                  "$brighter" \
                  | ${lib.getExe rofi} \
                      -theme-str '@import "brightness.rasi"' \
                      -hover-select \
                      -me-select-entry ''' \
                      -me-accept-entry MousePrimary \
                      -dmenu \
                      -sep ';' \
                      -selected-row 1)


              case "$chosen" in
                  "$dimmer")
                      ${lib.getExe pkgs.ddcutil} --display 1 setvcp 10 25; ${pkgs.ddcutil}/bin/ddcutil --disable-dynamic-sleep --display 2 setvcp 10 25
                      ;;

                  "$medium")
                      ${lib.getExe pkgs.ddcutil} --display 1 setvcp 10 75; ${pkgs.ddcutil}/bin/ddcutil --disable-dynamic-sleep --display 2 setvcp 10 75
                      ;;

                  "$brighter")
                      ${lib.getExe pkgs.ddcutil} --display 1 setvcp 10 100; ${pkgs.ddcutil}/bin/ddcutil --disable-dynamic-sleep --display 2 setvcp 10 100
                      ;;

                  *) exit 1 ;;
              esac

            ''
        )
      );
}
