{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.profiles.linux-base;
in

{

  options.nmasur.profiles.linux-base.enable = lib.mkEnableOption "Base Linux home-manager config";

  config = lib.mkIf cfg.enable {

    # Allow Nix to manage the default applications list
    xdg.mimeApps.enable = lib.mkDefault true;

    # Set directories for application defaults
    xdg.userDirs = {
      enable = lib.mkDefault true;
      createDirectories = lib.mkDefault true;
      documents = lib.mkDefault "$HOME/documents";
      download = lib.mkDefault "$HOME/downloads";
      music = lib.mkDefault "$HOME/media/music";
      pictures = lib.mkDefault "$HOME/media/images";
      videos = lib.mkDefault "$HOME/media/videos";
      desktop = lib.mkDefault "$HOME/other/desktop";
      publicShare = lib.mkDefault "$HOME/other/public";
      templates = lib.mkDefault "$HOME/other/templates";
      extraConfig = {
        XDG_DEV_DIR = lib.mkDefault "$HOME/dev";
      };
    };

    programs.fish.shellAliases = {
      # Move files to XDG trash on the commandline
      trash = lib.mkDefault "${pkgs.trash-cli}/bin/trash-put";
    };
  };
}
