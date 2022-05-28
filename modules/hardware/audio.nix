{ config, pkgs, lib, ... }:

let

  # These micro-scripts change the volume while also triggering the volume
  # notification widget

  increaseVolume = pkgs.writeShellScriptBin "increaseVolume" ''
    ${pkgs.pamixer}/bin/pamixer -i 2
    volume=$(${pkgs.pamixer}/bin/pamixer --get-volume)
    ${pkgs.volnoti}/bin/volnoti-show $volume
  '';

  decreaseVolume = pkgs.writeShellScriptBin "decreaseVolume" ''
    ${pkgs.pamixer}/bin/pamixer -d 2
    volume=$(${pkgs.pamixer}/bin/pamixer --get-volume)
    ${pkgs.volnoti}/bin/volnoti-show $volume
  '';

  toggleMute = pkgs.writeShellScriptBin "toggleMute" ''
    ${pkgs.pamixer}/bin/pamixer --toggle-mute
    mute=$(${pkgs.pamixer}/bin/pamixer --get-mute)
    if [ "$mute" == "true" ]; then
        ${pkgs.volnoti}/bin/volnoti-show --mute
    else
        volume=$(${pkgs.pamixer}/bin/pamixer --get-volume)
        ${pkgs.volnoti}/bin/volnoti-show $volume
    fi
  '';

in {

  config = lib.mkIf config.gui.enable {
    sound.enable = true;
    hardware.pulseaudio.enable = true;

    environment.systemPackages = with pkgs; [
      pamixer # Audio control
      volnoti # Volume notifications
    ];

    home-manager.users.${config.user} = {

      # Graphical volume notifications
      services.volnoti.enable = true;

      # i3 keybinds for changing the volume
      xsession.windowManager.i3.config.keybindings = {
        "XF86AudioRaiseVolume" =
          "exec --no-startup-id ${increaseVolume}/bin/increaseVolume";
        "XF86AudioLowerVolume" =
          "exec --no-startup-id ${decreaseVolume}/bin/decreaseVolume";
        "XF86AudioMute" = "exec --no-startup-id ${toggleMute}/bin/toggleMute";
        "XF86AudioMicMute" =
          "exec --no-startup-id pamixer --default-source --toggle-mute";
      };

    };
  };

}
