{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.noti;
in

{

  options.nmasur.presets.programs.noti.enable = lib.mkEnableOption "Noti CLI notifications";

  config = lib.mkIf (cfg.enable && (pkgs.stdenv.isDarwin || config.services.dunst.enable)) {
    home.packages = [ pkgs.noti ];
    programs.fish.shellAbbrs = {
      # Add noti for ghpr in Darwin
      ghpr = lib.mkForce "gh pr create && sleep 3 && noti gh run watch";
      grw = lib.mkForce "noti gh run watch";
    };
  };
}
