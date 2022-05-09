{ pkgs, lib, user, ... }: {

  home-manager.users.${user} = {

    home.packages = with pkgs; [ himalaya ];

    programs.himalaya = {
      enable = true;
      settings = {
        name = "${name}";
        downloads-dir = "~/Downloads";
        home = {
          default = true;
          email = "censored";
          imap-host = "censored";
          imap-port = 993;
          imap-login = "censored";
          imap-passwd-cmd = "cat ~/.config/himalaya/passwd";
          smtp-host = "censored";
          smtp-port = 587;
          smtp-login = "censored";
          smtp-passwd-cmd = "cat ~/.config/himalaya/passwd";
        };
      };
    };
  };
}
