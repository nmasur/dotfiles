{ pkgs, lib, gui, user, ... }: {

  config = lib.mkIf gui {
    nixpkgs.config.allowUnfree = true;
    home-manager.users.${user} = {
      home.packages = with pkgs; [ _1password-gui ];
    };
  };
}
