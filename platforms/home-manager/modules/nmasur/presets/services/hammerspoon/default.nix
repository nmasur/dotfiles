{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.services.hammerspoon;
  # inherit (config.nmasur.settings) username;
in

{

  options.nmasur.presets.services.hammerspoon.enable =
    lib.mkEnableOption "Hammerspoon macOS automation";

  config = lib.mkIf cfg.enable {

    home.file.".Brewfile".text = /* homebrew */ ''
      cask "hammerspoon" # Different scroll style for mouse vs. trackpad
    '';

    targets.darwin.defaults = {
      "org.hammerspoon.Hammerspoon" = {
        MJConfigFile = "${config.xdg.configHome}/hammerspoon/init.lua";
      };
    };

    xdg.configFile."hammerspoon/init.lua".source = ./init.lua;
    xdg.configFile."hammerspoon/Spoons/ControlEscape.spoon".source = ./Spoons/ControlEscape.spoon;
    xdg.configFile."hammerspoon/Spoons/DismissAlerts.spoon".source = ./Spoons/DismissAlerts.spoon;
    xdg.configFile."hammerspoon/Spoons/Launcher.spoon/init.lua".source =
      pkgs.replaceVars ./Spoons/Launcher.spoon/init.lua
        {
          discord = "${pkgs.discord}/Applications/Discord.app";
          firefox = "${pkgs.firefox-unwrapped}/Applications/Firefox.app";
          obsidian = "${pkgs.obsidian}/Applications/Obsidian.app";
          slack = "${pkgs.slack}/Applications/Slack.app";
          wezterm = "${pkgs.wezterm}/Applications/WezTerm.app";
          zed = "${config.programs.zed-editor.package}/Applications/Zed.app";
        };
    xdg.configFile."hammerspoon/Spoons/MoveWindow.spoon".source = ./Spoons/MoveWindow.spoon;
    xdg.configFile."hammerspoon/Spoons/HideZoomWindow.spoon".source = ./Spoons/HideZoomWindow.spoon;

    home.activation.reloadHammerspoon = config.lib.dag.entryAfter [ "writeBoundary" ] ''
      # The `hs` CLI blocks forever on Hammerspoon's IPC message port when the
      # app isn't running (|| true can't help — it never returns). Only reload
      # when the app is actually up, and wrap each call in `timeout` as a hard
      # backstop so activation can never hang even if IPC is unresponsive.
      hs=/Applications/Hammerspoon.app/Contents/Frameworks/hs/hs
      if /usr/bin/pgrep -x Hammerspoon > /dev/null 2>&1; then
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/timeout 10 "$hs" -c "hs.reload()" || true
        $DRY_RUN_CMD sleep 1
        $DRY_RUN_CMD ${pkgs.coreutils}/bin/timeout 10 "$hs" -c "hs.console.clearConsole()" || true
      else
        verboseEcho "Hammerspoon not running; skipping reload."
      fi
    '';
  };

}
