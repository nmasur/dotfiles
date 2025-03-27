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

    security = {

      # Remove sudo
      sudo.enable = false;

      # Add doas
      doas = {
        enable = true;

        # No password required for trusted users
        wheelNeedsPassword = false;

        # Pass environment variables from user to root
        # Also requires specifying that we are removing password here
        extraRules = [
          {
            groups = [ "wheel" ];
            noPass = true;
            keepEnv = true;
          }
        ];
      };
    };

  };
}
