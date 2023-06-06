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
        config = {
          image-display-duration = 2;
          hwdec = "auto-safe";
        };
        scripts = [

          # Automatically load playlist entries before and after current file
          pkgs.mpvScripts.autoload

          # Delete current file after quitting
          (pkgs.stdenv.mkDerivation rec {
            pname = "mpv-delete-file";
            version = "0.1"; # made-up
            src = pkgs.fetchFromGitHub {
              owner = "zenyd";
              repo = "mpv-scripts";
              rev = "19ea069abcb794d1bf8fac2f59b50d71ab992130";
              sha256 = "sha256-OBCuzCtgfSwj0i/rBNranuu4LRc47jObwQIJgQQoerg=";
            } + "/delete_file.lua";
            dontBuild = true;
            dontUnpack = true;
            installPhase =
              "install -Dm644 ${src} $out/share/mpv/scripts/delete_file.lua";
            passthru.scriptName = "delete_file.lua";
          })
        ];
      };

      # Set default for opening PDFs
      xdg.mimeApps = {
        associations.added = {
          "application/pdf" = [ "pwmt.zathura-cb.desktop" ];
          "image/jpeg" = [ "nsxiv.desktop" ];
          "image/*" = [ "nsxiv.desktop" ];
        };
        associations.removed = {
          "application/pdf" = [ "mupdf.desktop" "wine-extension-pdf.desktop" ];
        };
        defaultApplications = {
          "application/pdf" = [ "pwmt.zathura-cb.desktop" ];
          "image/jpeg" = [ "nsxiv.desktop" ];
          "image/*" = [ "nsxiv.desktop" ];
        };
      };

    };

  };

}
