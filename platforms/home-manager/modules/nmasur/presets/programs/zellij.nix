{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.zellij;
in

{

  options.nmasur.presets.programs.zellij.enable = lib.mkEnableOption "Zellij terminal multiplexer";

  config = lib.mkIf cfg.enable {

    programs.zellij = {

      enable = true;
      enableBashIntegration = true;
      enableFishIntegration = true;
      enableZshIntegration = true;

      settings = {
        theme = "custom";
        themes.custom = {
          fg = "${config.theme.colors.base05}";
          bg = "${config.theme.colors.base02}";
          black = "${config.theme.colors.base00}";
          red = "${config.theme.colors.base08}";
          green = "${config.theme.colors.base0B}";
          yellow = "${config.theme.colors.base0A}";
          blue = "${config.theme.colors.base0D}";
          magenta = "${config.theme.colors.base0E}";
          cyan = "${config.theme.colors.base0C}";
          white = "${config.theme.colors.base05}";
          orange = "${config.theme.colors.base09}";
        };
      };

    };

  };

}
