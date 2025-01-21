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
    mimeApps.enable = true;

    # Set directories for application defaults
    userDirs = {
      enable = true;
      createDirectories = true;
      documents = "$HOME/documents";
      download = config.userDirs.download;
      music = "$HOME/media/music";
      pictures = "$HOME/media/images";
      videos = "$HOME/media/videos";
      desktop = "$HOME/other/desktop";
      publicShare = "$HOME/other/public";
      templates = "$HOME/other/templates";
      extraConfig = {
        XDG_DEV_DIR = "$HOME/dev";
      };
    };

    programs.fish.shellAliases = {
      # Move files to XDG trash on the commandline
      trash = "${pkgs.trash-cli}/bin/trash-put";
    };
  };
}
