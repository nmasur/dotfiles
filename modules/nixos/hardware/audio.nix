{
  config,
  pkgs,
  lib,
  ...
}:

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
in
{

  config = lib.mkIf (pkgs.stdenv.isLinux && config.gui.enable) {
    # Enable PipeWire
    services.pipewire = {
      enable = true;
      pulse.enable = true;
    };

    # Provides audio source with background noise filtered
    programs.noisetorch.enable = true;

    # These aren't necessary, but helpful for the user
    environment.systemPackages = with pkgs; [
      pamixer # Audio control
      volnoti # Volume notifications
    ];

    home-manager.users.${config.user} = {

      # Graphical volume notifications
      services.volnoti.enable = true;

      xsession.windowManager.i3.config = {

        # Make sure that Volnoti actually starts (home-manager doesn't start
        # user daemon's automatically)
        startup = [
          {
            command = "systemctl --user restart volnoti --alpha 0.15 --radius 40 --timeout 0.2";
            always = true;
            notification = false;
          }
        ];

        # i3 keybinds for changing the volume
        keybindings = {
          "XF86AudioRaiseVolume" = "exec --no-startup-id ${increaseVolume}/bin/increaseVolume";
          "XF86AudioLowerVolume" = "exec --no-startup-id ${decreaseVolume}/bin/decreaseVolume";
          "XF86AudioMute" = "exec --no-startup-id ${toggleMute}/bin/toggleMute";
          # We can mute the mic by adding "--default-source"
          "XF86AudioMicMute" = "exec --no-startup-id ${pkgs.pamixer}/bin/pamixer --default-source --toggle-mute";
        };
      };
    };
  };
}
