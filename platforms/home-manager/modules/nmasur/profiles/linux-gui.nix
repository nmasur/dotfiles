{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.linux-gui;
in

{

  options.nmasur.profiles.linux-gui.enable = lib.mkEnableOption "Linux GUI home";

  config = lib.mkIf cfg.enable {

    nmasur.gtk.enable = lib.mkDefault true;
    programs.zed-editor.enable = lib.mkDefault true;

  };
}
