{ pkgs, lib, identity, ... }: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${identity.user} = {

    home.packages = with pkgs; [
      # neomutt
      qbittorrent

      # Encryption
      gnupg
      pass
    ];

    home.sessionVariables = {
      NOTES_PATH = "/home/${identity.user}/dev/personal/notes";
    };

  };
}
