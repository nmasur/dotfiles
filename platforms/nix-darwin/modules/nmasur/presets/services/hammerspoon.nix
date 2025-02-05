{
  config,
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

    homebrew.casks = [ "hammerspoon" ];

    system.activationScripts.postUserActivation.text = ''
      defaults write org.hammerspoon.Hammerspoon MJConfigFile "${
        config.home-manager.users.${config.user}.xdg.configHome
      }/hammerspoon/init.lua"
      sudo killall Dock
    '';

  };

}
