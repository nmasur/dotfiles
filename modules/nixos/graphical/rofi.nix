{
  config,
  pkgs,
  lib,
  ...
}:

let

  rofi = config.home-manager.users.${config.user}.programs.rofi.finalPackage;
in
{

  imports = [
    ./rofi/power.nix
    ./rofi/brightness.nix
  ];

  config = lib.mkIf (pkgs.stdenv.isLinux && config.services.xserver.enable) {

    launcherCommand = ''${rofi}/bin/rofi -modes drun -show drun -theme-str '@import "launcher.rasi"' '';
    systemdSearch = "${pkgs.rofi-systemd}/bin/rofi-systemd";
    altTabCommand = "${rofi}/bin/rofi -show window -modi window";
    calculatorCommand = "${rofi}/bin/rofi -modes calc -show calc";
    audioSwitchCommand = "${
      (pkgs.writeShellApplication {
        name = "switch-audio";
        runtimeInputs = [
          pkgs.ponymix
          rofi
        ];
        text = builtins.readFile ./rofi/pulse-sink.sh;
      })
    }/bin/switch-audio";
  };
}
