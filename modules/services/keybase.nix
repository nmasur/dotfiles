{ pkgs, lib, user, gui, ... }: {

  services.keybase.enable = true;
  services.kbfs.enable = true;

  home-manager.users.${user}.home.packages =
    [ (lib.mkIf gui pkgs.keybase-gui) ];

}
