{ config, pkgs, lib, ... }: {

  config = lib.mkIf config.gui.enable {
    home-manager.users.${config.user}.home.packages = with pkgs; [
      mpv # Video viewer
      sxiv # Image viewer
      zathura # PDF viewer
    ];
  };

}
