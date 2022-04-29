{ pkgs, lib, user, gui, ... }:

{
  home-manager.users.${user}.home.packages = [ (lib.mkIf gui pkgs.firefox) ];
}
