{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.hammerspoon;
in

{

  options.nmasur.presets.services.hammerspoon.enable =
    lib.mkEnableOption "Hammerspoon macOS automation";

  config = lib.mkIf cfg.enable {
    xdg.configFile."hammerspoon/init.lua".source = ./init.lua;
    xdg.configFile."hammerspoon/Spoons/ControlEscape.spoon".source = ./Spoons/ControlEscape.spoon;
    xdg.configFile."hammerspoon/Spoons/DismissAlerts.spoon".source = ./Spoons/DismissAlerts.spoon;
    xdg.configFile."hammerspoon/Spoons/Launcher.spoon/init.lua".source =
      pkgs.replaceVars ./Spoons/Launcher.spoon/init.lua
        {
          discord = "${pkgs.discord}/Applications/Discord.app";
          firefox = "${pkgs.firefox-unwrapped}/Applications/Firefox.app";
          ghostty = "${config.programs.ghostty.package}/Applications/Ghostty.app";
          obsidian = "${pkgs.obsidian}/Applications/Obsidian.app";
          slack = "${pkgs.slack}/Applications/Slack.app";
          wezterm = "${pkgs.wezterm}/Applications/WezTerm.app";
          zed = "${pkgs.zed-editor}/Applications/Zed.app";
        };
    xdg.configFile."hammerspoon/Spoons/MoveWindow.spoon".source = ./Spoons/MoveWindow.spoon;

    home.activation.reloadHammerspoon = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      $DRY_RUN_CMD /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs -c "hs.reload()"
      $DRY_RUN_CMD sleep 1
      $DRY_RUN_CMD /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs -c "hs.console.clearConsole()"
    '';
  };

}
