{ config, pkgs, ... }: {

  home-manager.users.${config.user}.home.packages = with pkgs;
    [
      stylua # Lua formatter
    ];

}
