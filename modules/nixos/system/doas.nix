# Replace sudo with doas

{ config, pkgs, lib, ... }: {

  config = lib.mkIf pkgs.stdenv.isLinux {

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
        extraRules = [{
          groups = [ "wheel" ];
          noPass = true;
          keepEnv = true;
        }];
      };
    };

    # Alias sudo to doas for convenience
    home-manager.users.${config.user}.programs.fish.shellAliases = {
      sudo = "doas";
    };

  };

}
