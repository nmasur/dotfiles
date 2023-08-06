{ config, pkgs, lib, ... }:

let

  # Based on: https://gitlab.com/rycee/nur-expressions/-/blob/7ae92e3497e1f1805fb849510120e2ee393018cd/pkgs/materia-theme/default.nix
  gtkTheme = pkgs.stdenv.mkDerivation rec {
    pname = "materia-custom";
    version = "20210322";
    src = pkgs.fetchFromGitHub {
      owner = "nana-4";
      repo = "materia-theme";
      rev = "v${version}";
      sha256 = "1fsicmcni70jkl4jb3fvh7yv0v9jhb8nwjzdq8vfwn256qyk0xvl";
    };
    nativeBuildInputs = with pkgs; [
      bc
      optipng
      sassc

      (runCommandLocal "rendersvg" { } ''
        mkdir -p $out/bin
        ln -s ${resvg}/bin/resvg $out/bin/rendersvg
      '')
    ];

    dontConfigure = true;

    # Fixes problem "Fontconfig error: Cannot load default config file"
    FONTCONFIG_FILE =
      pkgs.makeFontsConf { fontDirectories = [ pkgs.cantarell-fonts ]; };

    # Derivation adds an extra # so we need to remove it from our colorscheme
    theme = let stripHash = color: lib.strings.removePrefix "#" color;
    in lib.generators.toKeyValue { } {
      # Color selection copied from
      # https://github.com/pinpox/nixos-home/blob/1cefe28c72930a0aed41c20d254ad4d193a3fa37/gtk.nix#L11
      ACCENT_BG = stripHash config.theme.colors.base0B;
      ACCENT_FG = stripHash config.theme.colors.base00;
      BG = stripHash config.theme.colors.base00;
      BTN_BG = stripHash config.theme.colors.base02;
      BTN_FG = stripHash config.theme.colors.base06;
      FG = stripHash config.theme.colors.base05;
      HDR_BG = stripHash config.theme.colors.base02;
      HDR_BTN_BG = stripHash config.theme.colors.base01;
      HDR_BTN_FG = stripHash config.theme.colors.base05;
      HDR_FG = stripHash config.theme.colors.base05;
      MATERIA_SURFACE = stripHash config.theme.colors.base01;
      MATERIA_VIEW = stripHash config.theme.colors.base01;
      MENU_BG = stripHash config.theme.colors.base02;
      MENU_FG = stripHash config.theme.colors.base06;
      SEL_BG = stripHash config.theme.colors.base04;
      SEL_FG = stripHash config.theme.colors.base05;
      TXT_BG = stripHash config.theme.colors.base02;
      TXT_FG = stripHash config.theme.colors.base07;
      WM_BORDER_FOCUS = stripHash config.theme.colors.base03;
      WM_BORDER_UNFOCUS = stripHash config.theme.colors.base02;

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
      ./change_color.sh \
         -i False \
         -t $out/share/themes \
         -o "materia-custom" \
         "$themePath"
    '';
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
