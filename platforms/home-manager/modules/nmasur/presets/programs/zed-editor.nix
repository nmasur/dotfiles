{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.zed-editor;
in

{

  options.nmasur.presets.programs.zed-editor.enable = lib.mkEnableOption "Zed text editor";

  config = lib.mkIf cfg.enable {
    programs.zed-editor = {
      enable = true;
      package = pkgs.stable.zed-editor;

      extensions = [
        "nix"
        "rust"
      ];

      extraPackages = [ pkgs.nixd ];

      installRemoteServer = false;

      userKeymaps = [
        {
          context = "Workspace";
          bindings = {
            ctrl-shift-t = "workspace::NewTerminal";
          };
        }
      ];

      userSettings = {
        features = {
          copilot = false;
        };
        telemetry = {
          metrics = false;
        };
        vim_mode = true;
        ui_font_size = 16;
        buffer_font_size = 16;
      };

    };

  };
}
