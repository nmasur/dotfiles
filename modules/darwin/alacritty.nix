{ config, pkgs, lib, ... }: {

  # MacOS-specific settings for Alacritty
  home-manager.users.${config.user} = {
    programs.alacritty.settings = {
      font.size = lib.mkForce 18.0;
      shell.program = "${pkgs.fish}/bin/fish";
      key_bindings = [
        {
          key = "F";
          mods = "Super";
          action = "ToggleSimpleFullscreen";
        }
        {
          key = "L";
          mods = "Super";
          chars = "\\x1F";
        }
      ];
    };
  };

}
