{ config, pkgs, lib, ... }: {

  options = {
    media = {
      enable = lib.mkEnableOption {
        description = "Enable media programs.";
        default = false;
      };
    };
  };

  config = lib.mkIf (config.gui.enable && config.media.enable) {
    home-manager.users.${config.user} = {
      home.packages = with pkgs; [
        mpv # Video viewer
        sxiv # Image viewer
        mupdf # PDF viewer
        zathura # PDF viewer
        yt-dlp # Video downloader
      ];

      # Set default for opening PDFs
      xdg.mimeApps.defaultApplications."application/pdf" =
        [ "zathura.desktop" ];
      xdg.mimeApps.defaultApplications."image/*" = [ "sxiv.desktop" ];

    };

  };

}
