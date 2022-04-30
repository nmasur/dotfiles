{ pkgs, lib, identity, gui, ... }: {

  config = lib.mkIf gui.enable {
    home-manager.users.${identity.user} = {
      nixpkgs.config.allowUnfree = true;
      home.packages = with pkgs; [ discord ];
    };
  };
}
