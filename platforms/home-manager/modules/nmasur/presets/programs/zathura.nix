{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.zathura;
in

{

  options.nmasur.presets.programs.zathura.enable = lib.mkEnableOption "Zathura PDF viewer";

  config = lib.mkIf cfg.enable {
    home.packages = with pkgs; [
      zathura # PDF viewer
    ];
    # Set default program for opening PDFs
    xdg.mimeApps = {
      associations.added = {
        "application/pdf" = [ "pwmt.zathura-cb.desktop" ];
      };
      associations.removed = {
        "application/pdf" = [
          "mupdf.desktop"
          "wine-extension-pdf.desktop"
        ];
      };
      defaultApplications = {
        "application/pdf" = [ "pwmt.zathura-cb.desktop" ];
      };
    };
  };
}
