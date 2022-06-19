{ config, ... }: {

  home-manager.users.${config.user}.programs.alacritty.settings.key_bindings =
    [{
      key = "F";
      mods = "Super";
      action = "ToggleSimpleFullscreen";
    }];

}
