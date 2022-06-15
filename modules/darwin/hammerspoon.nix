{ config, ... }: {

  # Hammerspoon - MacOS custom automation scripting

  home-manager.users.${config.user} = {
    xdg.configFile.hammerspoon = { source = ./hammerspoon; };
  };

  homebrew.casks = [ "hammerspoon" ];

  system.activationScripts.hammerspoon.text = ''
    defaults write org.hammerspoon.Hammerspoon MJConfigFile "~/.config/hammerspoon/init.lua"
  '';

}
