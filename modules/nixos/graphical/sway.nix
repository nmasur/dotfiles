{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {

    programs.sway.enable = true;

  };

  home-manager.users.${config.user} = {

    wayland.windowManager.sway.enable = true;
    wayland.windowManager.sway.config =
      config.home-manager.users.${config.user}.xsession.windowManager.i3.config;

  };

  # TODO: swaybg
  # TODO: swaylock

}
