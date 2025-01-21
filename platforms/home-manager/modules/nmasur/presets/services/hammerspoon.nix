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
    xdg.configFile."hammerspoon/init.lua".source = ./hammerspoon/init.lua;
    xdg.configFile."hammerspoon/Spoons/ControlEscape.spoon".source =
      ./hammerspoon/Spoons/ControlEscape.spoon;
    xdg.configFile."hammerspoon/Spoons/DismissAlerts.spoon".source =
      ./hammerspoon/Spoons/DismissAlerts.spoon;
    xdg.configFile."hammerspoon/Spoons/Launcher.spoon/init.lua".source = pkgs.substituteAll {
      src = ./hammerspoon/Spoons/Launcher.spoon/init.lua;
      firefox = "${pkgs.firefox-bin}/Applications/Firefox.app";
      discord = "${pkgs.discord}/Applications/Discord.app";
      wezterm = "${pkgs.wezterm}/Applications/WezTerm.app";
      obsidian = "${pkgs.obsidian}/Applications/Obsidian.app";
      slack = "${pkgs.slack}/Applications/Slack.app";
    };
    xdg.configFile."hammerspoon/Spoons/MoveWindow.spoon".source = ./hammerspoon/Spoons/MoveWindow.spoon;

    home.activation.reloadHammerspoon =
      config.home-manager.users.${config.user}.lib.dag.entryAfter [ "writeBoundary" ]
        ''
          $DRY_RUN_CMD /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs -c "hs.reload()"
          $DRY_RUN_CMD sleep 1
          $DRY_RUN_CMD /Applications/Hammerspoon.app/Contents/Frameworks/hs/hs -c "hs.console.clearConsole()"
        '';
  };

}
