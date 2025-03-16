{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.ghostty;
in

{

  options.nmasur.presets.programs.ghostty.enable = lib.mkEnableOption "Ghostty terminal";

  config = lib.mkIf cfg.enable {
    programs.ghostty = {
      enable = true;

      package = if pkgs.stdenv.isDarwin then pkgs.nur.repos.DimitarNestorov.ghostty else pkgs.ghostty;

      enableFishIntegration = true;
      enableBashIntegration = true;
      enableZshIntegration = true;
      installBatSyntax = true;
      settings = {
        theme = config.theme.name;
        font-size = 16;
      };
      themes."gruvbox" = {
        background = config.theme.colors.base00;
        cursor-color = config.theme.colors.base04;
        foreground = config.theme.colors.base05;
        palette = [
          "0=${config.theme.colors.base00}"
          "1=${config.theme.colors.base08}"
          "2=${config.theme.colors.base0B}"
          "3=${config.theme.colors.base0A}"
          "4=${config.theme.colors.base0D}"
          "5=${config.theme.colors.base0E}"
          "6=${config.theme.colors.base0C}"
          "7=${config.theme.colors.base05}"
          "8=${config.theme.colors.base03}"
          "9=${config.theme.colors.base08}"
          "10=${config.theme.colors.base0B}"
          "11=${config.theme.colors.base0A}"
          "12=${config.theme.colors.base0C}"
          "13=${config.theme.colors.base0E}"
          "14=${config.theme.colors.base0C}"
          "15=${config.theme.colors.base07}"
          "16=${config.theme.colors.base09}"
          "17=${config.theme.colors.base0F}"
          "18=${config.theme.colors.base01}"
          "19=${config.theme.colors.base02}"
          "20=${config.theme.colors.base04}"
          "21=${config.theme.colors.base06}"
        ];
        selection-background = config.theme.colors.base02;
        selection-foreground = config.theme.colors.base00;
      };

    };

  };
}
