{ config, lib, ... }: {

  config = lib.mkIf config.gui.enable {

    programs.sway = {
      enable = true;
      package = null; # Use home-manager Sway instead
    };

  };

  home-manager.users.${config.user} = {

    wayland.windowManager.sway = {
      enable = true;
      config =
        config.home-manager.users.${config.user}.xsession.windowManager.i3.config;
    };

  };

  # TODO: swaybg
  # TODO: swaylock

}
