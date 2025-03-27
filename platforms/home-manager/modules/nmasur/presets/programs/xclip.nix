{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.xclip;
in

{

  options.nmasur.presets.programs.xclip.enable = lib.mkEnableOption "xclip keyboard";

  config = lib.mkIf cfg.enable {

    home.packages = [ pkgs.xclip ];

    programs.fish.shellAliases = {
      pbcopy = "xclip -selection clipboard -in";
      pbpaste = "xclip -selection clipboard -out";
    };
  };
}
