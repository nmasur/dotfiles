{
  config,
  pkgs,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.fish-darwin;
in

{

  options.nmasur.presets.programs.fish-darwin.enable = lib.mkEnableOption {
    description = "Fish macOS options";
    default = config.nmasur.presets.programs.fish && pkgs.stdenv.isDarwin;
  };

  config = lib.mkIf cfg.enable {
    programs.fish.shellAbbrs = {
      # Shortcut to edit hosts file
      hosts = "sudo nvim /etc/hosts";
    };
  };
}
