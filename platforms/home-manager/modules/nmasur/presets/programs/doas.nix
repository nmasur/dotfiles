{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.programs.doas;
in

{

  options.nmasur.presets.programs.doas.enable = lib.mkEnableOption "doas sudo alternative";

  config = lib.mkIf cfg.enable {

    # Alias sudo to doas for convenience
    fish.shellAliases = {
      sudo = "doas";
    };

    # Disable overriding our sudo alias with a TERMINFO alias
    kitty.settings.shell_integration = "no-sudo";
  };

}
