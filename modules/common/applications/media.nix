{
  config,
  pkgs,
  lib,
  ...
}:
{

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
        nsxiv # Image viewer
        mupdf # PDF viewer
        zathura # PDF viewer
      ];

      # Video player
      programs.mpv = {
        enable = true;
        bindings = { };
        config = {
          image-display-duration = 2; # For cycling through images
          hwdec = "auto-safe"; # Attempt to use GPU decoding for video
        };
        scripts = [

          # Automatically load playlist entries before and after current file
          pkgs.mpvScripts.autoload

          # Delete current file after quitting
          pkgs.mpvScripts.mpv-delete-file
        ];
      };

      # Set default programs for opening PDFs and other media
      xdg.mimeApps = {
        associations.added = {
          "application/pdf" = [ "pwmt.zathura-cb.desktop" ];
          "image/jpeg" = [ "nsxiv.desktop" ];
          "image/png" = [ "nsxiv.desktop" ];
          "image/*" = [ "nsxiv.desktop" ];
        };
        associations.removed = {
          "application/pdf" = [
            "mupdf.desktop"
            "wine-extension-pdf.desktop"
          ];
        };
        defaultApplications = {
          "application/pdf" = [ "pwmt.zathura-cb.desktop" ];
          "image/jpeg" = [ "nsxiv.desktop" ];
          "image/png" = [ "nsxiv.desktop" ];
          "image/*" = [ "nsxiv.desktop" ];
        };
      };
    };
  };
}
