{
  config,
  lib,
  pkgs,
  ...
}:

let
  cfg = config.nmasur.profiles.experimental;
in

{

  options.nmasur.profiles.experimental.enable = lib.mkEnableOption "experimental tools";

  config = lib.mkIf cfg.enable {

    home.packages = [

      # Charm tools

      pkgs.glow # Markdown previews
      pkgs.skate # Key-value store
      pkgs.charm # Manage account and filesystem
      pkgs.pop # Send emails from a TUI

    ];

    programs.gh-dash.enable = lib.mkDefault true;
    programs.helix.enable = lib.mkDefault true;
    programs.zed-editor.enable = lib.mkDefault true;
    programs.himalaya.enable = lib.mkDefault true;

  };

}
