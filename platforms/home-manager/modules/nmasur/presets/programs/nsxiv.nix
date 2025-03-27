{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.nsxiv;
in

{

  options.nmasur.presets.programs.nsxiv.enable = lib.mkEnableOption "Neo Simple X Image Viewer";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      nsxiv # Image viewer
    ];

    # Set default program for opening images
    xdg.mimeApps = {
      associations.added = {
        "image/jpeg" = [ "nsxiv.desktop" ];
        "image/png" = [ "nsxiv.desktop" ];
        "image/*" = [ "nsxiv.desktop" ];
      };
      defaultApplications = {
        "image/jpeg" = [ "nsxiv.desktop" ];
        "image/png" = [ "nsxiv.desktop" ];
        "image/*" = [ "nsxiv.desktop" ];
      };
    };
  };
}
