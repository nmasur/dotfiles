{ config, pkgs, lib, ... }:

let

  # Based on: https://gitlab.com/rycee/nur-expressions/-/blob/7ae92e3497e1f1805fb849510120e2ee393018cd/pkgs/materia-theme/default.nix
  gtkTheme = pkgs.stdenv.mkDerivation {
    pname = "materia-custom";
    version = "0.1";
    src = pkgs.fetchFromGitHub {
      owner = "nana-4";
      repo = "materia-theme";
      rev = "6e5850388a25f424b8193fe4523504d1dc364175";
      sha256 = "sha256-I6hpH0VTmftU4+/pRbztuTQcBKcOFBFbNZXJL/2bcgU=";
    };
    # patches = [ ../../../overlays/materia-theme.patch ];
    nativeBuildInputs = with pkgs; [
      bc
      dart-sass
      optipng
      meson
      ninja
      sassc

      (runCommandLocal "rendersvg" { } ''
        mkdir -p $out/bin
        ln -s ${resvg}/bin/resvg $out/bin/rendersvg
      '')
    ];

    dontConfigure = true;

    # # Fixes problem "Fontconfig error: Cannot load default config file"
    # FONTCONFIG_FILE =
    #   pkgs.makeFontsConf { fontDirectories = [ pkgs.cantarell-fonts ]; };

    # Derivation adds an extra # so we need to remove it from our colorscheme
    theme = let stripHash = color: lib.strings.removePrefix "#" color;
    in lib.generators.toKeyValue { } {
      # Color selection copied from
      # https://github.com/pinpox/nixos-home/blob/1cefe28c72930a0aed41c20d254ad4d193a3fa37/gtk.nix#L11

      # Secondary accent
      ACCENT_BG = stripHash config.theme.colors.base0B;
      ACCENT_FG = stripHash config.theme.colors.base00;

      # Main colors
      BG = stripHash config.theme.colors.base00;
      FG = stripHash config.theme.colors.base05;

      # Buttons
      BTN_BG = stripHash config.theme.colors.base02;
      BTN_FG = stripHash config.theme.colors.base06;

      # Header bar
      HDR_BG = stripHash config.theme.colors.base01;
      HDR_BTN_BG = stripHash config.theme.colors.base02;
      HDR_BTN_FG = stripHash config.theme.colors.base05;
      HDR_FG = stripHash config.theme.colors.base05;

      # Not sure
      MATERIA_SURFACE = stripHash config.theme.colors.base03;
      MATERIA_VIEW = stripHash config.theme.colors.base08;

      # Not sure
      MENU_BG = stripHash config.theme.colors.base0A;
      MENU_FG = stripHash config.theme.colors.base0E;

      # Selection (primary accent)
      SEL_BG = stripHash config.theme.colors.base04;
      SEL_FG = stripHash config.theme.colors.base07;

      TXT_BG = stripHash config.theme.colors.base02;
      TXT_FG = stripHash config.theme.colors.base07;

      WM_BORDER_FOCUS = stripHash config.theme.colors.base0D;
      WM_BORDER_UNFOCUS = stripHash config.theme.colors.base0C;

      MATERIA_COLOR_VARIANT = if config.theme.dark then "dark" else "light";
      MATERIA_STYLE_COMPACT = "True";
      UNITY_DEFAULT_LAUNCHER_STYLE = "False";
    };

    passAsFile = [ "theme" ];

    postPatch = ''
      patchShebangs .

      sed -e '/handle-horz-.*/d' -e '/handle-vert-.*/d' \
        -i ./src/gtk-2.0/assets.txt
    '';

    buildPhase = ''
      export HOME="$NIX_BUILD_ROOT"
      mkdir -p $out/share/themes/materia-custom
      ./change_color.sh \
         -i False \
         -t $out/share/themes \
         -o "materia-custom" \
         "$themePath" # References the file "theme" from passAsFile
    '';

    dontInstall = true;
  };

in {

  config = lib.mkIf config.gui.enable {

    home-manager.users.${config.user} = {

      gtk = let
        gtkExtraConfig = {
          gtk-application-prefer-dark-theme = config.theme.dark;
        };
      in {
        enable = true;
        theme = {
          name = "materia-custom";
          package = gtkTheme;
        };
        gtk3.extraConfig = gtkExtraConfig;
        gtk4.extraConfig = gtkExtraConfig;
      };

    };

    # Make the login screen dark
    services.xserver.displayManager.lightdm.greeters.gtk.theme = {
      name = config.home-manager.users.${config.user}.gtk.theme.name;
      package = gtkTheme;
    };

    environment.sessionVariables = {
      GTK_THEME = config.home-manager.users.${config.user}.gtk.theme.name;
    };

  };

}
