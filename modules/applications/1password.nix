{ pkgs, lib, gui, identity, ... }: {

  config = lib.mkIf gui.enable {
    nixpkgs.config.allowUnfree = true;
    home-manager.users.${identity.user} = {
      home.packages = with pkgs; [ _1password-gui ];
    };
  };
}
