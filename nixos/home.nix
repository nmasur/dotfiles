{ pkgs, lib, ... }:

let

  editor = "nvim";
  font = "Victor Mono";
  dotfiles = builtins.toString ../.;
  nixos_config = builtins.toString ./.;
  notes_path = "$HOME/dev/personal/notes";

  ignore_patterns = ''
    !.env*
    !.github/
    !.gitignore
    !*.tfvars
    .terraform/
    .target/
    /Library/
    keybase/
    kbfs/
  '';

in {
  options = with lib; {
    user = mkOption { default = "noah"; };
    fullName = mkOption { default = "Noah Masur"; };
    font = mkOption { default = font; };
    nixos_config = mkOption { default = nixos_config; };
    dotfiles = mkOption { default = dotfiles; };
  };

  config = {
    nixpkgs.config.allowUnfree = true;

    home.packages = with pkgs; [
      # Applications
      _1password-gui
      discord
      # neomutt
      himalaya # Email
      mpv # Video viewer
      sxiv # Image viewer
      zathura # PDF viewer
      qbittorrent

      # Encryption
      gnupg
      pass
    ];

    gtk.enable = true;
    gtk.theme = { name = "Adwaita-dark"; };

    home.sessionVariables = {
      fish_greeting = "";
      EDITOR = "${editor}";
      NIXOS_CONFIG = "${nixos_config}";
      DOTS = "${dotfiles}";
      NOTES_PATH = "${notes_path}";
    };

    # Other configs
    xdg.configFile = {
      "awesome/rc.lua".source = ./awesomerc.lua;
      "qtile/config.py".source = ./qtile.py;
      "direnvrc".text = "source $HOME/.nix-profile/share/nix-direnv/direnvrc";
      "spectrwm/spectrwm.conf".source = ./spectrwm.conf;
    };
    home.file = {
      ".rgignore".text = ignore_patterns;
      ".fdignore".text = ignore_patterns;
    };

    programs.direnv = {
      enable = true;
      nix-direnv.enable = true;
      config = { whitelist = { prefix = [ "${dotfiles}/" ]; }; };
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
