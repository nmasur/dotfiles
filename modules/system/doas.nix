# Replace sudo with doas

{ identity, ... }: {

  security = {

    # Remove sudo
    sudo.enable = false;

    # Add doas
    doas = {
      enable = true;

      # No password required
      wheelNeedsPassword = false;

      # Pass environment variables from user to root
      # Also requires removing password here
      extraRules = [{
        groups = [ "wheel" ];
        noPass = true;
        keepEnv = true;
      }];
    };
  };

  home-manager.users.${identity.user}.programs.fish.shellAliases = {
    sudo = "doas";
  };
}
