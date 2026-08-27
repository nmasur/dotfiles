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

    # Set the i3 terminal
    nmasur.presets.services.i3.terminal = config.programs.ghostty.package;

    programs.ghostty = {
      enable = true;

      package = if pkgs.stdenv.hostPlatform.isDarwin then pkgs.ghostty-bin else pkgs.ghostty;

      enableFishIntegration = false; # Handled conditionally below to avoid conflicts inside Zellij/TMUX
      enableBashIntegration = true;
      enableZshIntegration = true;
      installBatSyntax = false; # The file doesn't seem to exist in the pkg
      settings = {
        theme = config.theme.name;
        font-size = 16;
        macos-titlebar-style = "hidden";
        window-decoration = false;
        macos-non-native-fullscreen = true;
        quit-after-last-window-closed = lib.mkIf pkgs.stdenv.hostPlatform.isDarwin true;
        fullscreen = if pkgs.stdenv.hostPlatform.isDarwin then true else false;
        keybind = [
          # Translate Mac Super & Ctrl combinations into Alt (ESC prefix) sequences
          # so Zellij receives them without needing Kitty keyboard protocol
          "super+t=text:\\x1bt"
          "super+shift+]=text:\\x1b}"
          "super+shift+[=text:\\x1b{"
          "ctrl+tab=text:\\x1b}"
          "ctrl+shift+tab=text:\\x1b{"
          "super+k=text:\\x1bK"
          "super+shift+e=text:\\x1bE"
        ];
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

    # Conditionally enable Ghostty fish shell integration only when NOT running inside multiplexers like Zellij/TMUX
    programs.fish.shellInit = ''
      if set -q GHOSTTY_RESOURCES_DIR; and not set -q ZELLIJ; and not set -q TMUX
        source "$GHOSTTY_RESOURCES_DIR/shell-integration/fish/vendor_conf.d/ghostty-shell-integration.fish"
      end
    '';

  };
}
