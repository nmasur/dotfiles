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
  # https://gitlab.com/vahnrr/rofi-menus/-/blob/b1f0e8a676eda5552e27ef631b0d43e660b23b8e/scripts/rofi-power
  # A rofi powered menu to execute power related action.

  config.powerCommand = lib.mkIf config.nmasur.presets.programs.rofi.enable builtins.toString (
    pkgs.writeShellScript "powermenu" ''
      power_off=''
      reboot=''
      lock=''
      suspend='󰒲'
      log_out=''

      chosen=$(printf '%s;%s;%s;%s;%s\n' \
          "$power_off" \
          "$reboot" \
          "$lock" \
          "$suspend" \
          "$log_out" \
          | ${lib.getExe rofi} \
              -theme-str '@import "power.rasi"' \
              -hover-select \
              -me-select-entry "" \
              -me-accept-entry MousePrimary \
              -dmenu \
              -sep ';' \
              -selected-row 2)

      confirm () {
          ${builtins.readFile ./rofi-prompt.sh}
      }

      case "$chosen" in
          "$power_off")
              confirm 'Shutdown?' && doas shutdown now
              ;;

          "$reboot")
              confirm 'Reboot?' && doas reboot
              ;;

          "$lock")
              ${lib.getExe pkgs.betterlockscreen} --lock --display 1 --blur 0.5 --span
              ;;

          "$suspend")
              systemctl suspend
              ;;

          "$log_out")
              confirm 'Logout?' && i3-msg exit
              ;;

          *) exit 1 ;;
      esac
    ''
  );
}
