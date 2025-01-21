{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.prettyping;
in

{

  options.nmasur.presets.programs.prettyping.enable =
    lib.mkEnableOption "Prettyping server ping tool";

  config = lib.mkIf cfg.enable {
    programs.fish.functions = {
      ping = {
        description = "Improved ping";
        argumentNames = "target";
        body = "${pkgs.prettyping}/bin/prettyping --nolegend $target";
      };
    };
  };
}
