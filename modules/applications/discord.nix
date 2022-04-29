{ pkgs, lib, user, gui, ... }: {

  config = lib.mkIf gui {
    home-manager.users.${user} = {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [ discord ];
    };
  };
}
