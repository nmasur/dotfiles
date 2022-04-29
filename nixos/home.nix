{ pkgs, lib, user, ... }: {
  home-manager.useGlobalPkgs = true;
  home-manager.useUserPackages = true;
  home-manager.users.${user} = {

    home.packages = with pkgs; [
      # neomutt
      himalaya # Email
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

    # Email
    # programs.himalaya = {
    # enable = true;
    # settings = {
    # name = "${name}";
    # downloads-dir = "~/Downloads";
    # home = {
    # default = true;
    # email = "censored";
    # imap-host = "censored";
    # imap-port = 993;
    # imap-login = "censored";
    # imap-passwd-cmd = "cat ~/.config/himalaya/passwd";
    # smtp-host = "censored";
    # smtp-port = 587;
    # smtp-login = "censored";
    # smtp-passwd-cmd = "cat ~/.config/himalaya/passwd";
    # };
    # };
    # };
  };
}
