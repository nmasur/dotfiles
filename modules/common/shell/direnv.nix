{ config, ... }: {

  # Enables quickly entering Nix shells when changing directories
  home-manager.users.${config.user}.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = { whitelist = { prefix = [ config.dotfilesPath ]; }; };
  };

  # Prevent garbage collection
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';

}
