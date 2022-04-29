{ pkgs, lib, user, ... }: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${user} = {

    home.packages = with pkgs; [
      # neomutt
      qbittorrent

      # Encryption
      gnupg
      pass
    ];

    home.sessionVariables = {
      NIXOS_CONFIG = builtins.toString ./.;
      DOTS = builtins.toString ../.;
      NOTES_PATH = "$HOME/dev/personal/notes";
    };

  };
}
