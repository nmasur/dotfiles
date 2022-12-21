{ config, pkgs, ... }: {

  # Hammerspoon - MacOS custom automation scripting

  home-manager.users.${config.user} = {
    xdg.configFile."hammerspoon/init.lua".source = ./hammerspoon/init.lua;
    xdg.configFile."hammerspoon/Spoons/ControlEscape.spoon".source =
      ./hammerspoon/Spoons/ControlEscape.spoon;
    xdg.configFile."hammerspoon/Spoons/DismissAlerts.spoon".source =
      ./hammerspoon/Spoons/DismissAlerts.spoon;
    xdg.configFile."hammerspoon/Spoons/Launcher.spoon/init.lua".source =
      pkgs.substituteAll {
        src = ./hammerspoon/Spoons/Launcher.spoon/init.lua;
        firefox = "${pkgs.firefox-bin}/Applications/Firefox.app";
        discord = "${pkgs.discord}/Applications/Discord.app";
        kitty = "${pkgs.kitty}/Applications/kitty.app";
      };
    xdg.configFile."hammerspoon/Spoons/MoveWindow.spoon".source =
      ./hammerspoon/Spoons/MoveWindow.spoon;
  };

  homebrew.casks = [ "hammerspoon" ];

  system.activationScripts.postUserActivation.text = ''
    defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
  '';

}
