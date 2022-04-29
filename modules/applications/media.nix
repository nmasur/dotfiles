{ pkgs, lib, gui, user, ... }: {

  config = lib.mkIf gui {
    home-manager.users.${user}.home.packages = with pkgs; [
      mpv # Video viewer
      sxiv # Image viewer
      zathura # PDF viewer
    ];
  };

}
