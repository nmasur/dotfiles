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
        nsxiv # Image viewer
        mupdf # PDF viewer
        zathura # PDF viewer
      ];

      # Video player
      programs.mpv = {
        enable = true;
        bindings = { };
        config = { image-display-duration = 2; };
        scripts = [ pkgs.mpvScripts.autoload ];
      };

      # Set default for opening PDFs
      xdg.mimeApps = {
        associations.added = {
          "application/pdf" = [ "pwmt.zathura-cb.desktop" ];
          "image/*" = [ "nsxiv.desktop" ];
        };
        associations.removed = { "application/pdf" = [ "mupdf.desktop" ]; };
        defaultApplications = {
          "application/pdf" = [ "pwmt.zathura-cb.desktop" ];
          "image/*" = [ "nsxiv.desktop" ];
        };
      };

    };

  };

}
