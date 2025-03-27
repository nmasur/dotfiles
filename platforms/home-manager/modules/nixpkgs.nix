{ config, lib, ... }:
{

  options = {
    allowUnfreePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of unfree packages to allow.";
      default = [ ];
    };
    allowInsecurePackages = lib.mkOption {
      type = lib.types.listOf lib.types.str;
      description = "List of insecure packages to allow.";
      default = [ ];
    };
  };

  config = {

    # # Allow specified unfree packages (identified elsewhere)
    # # Retrieves package object based on string name
    # nixpkgs.config.allowUnfreePredicate =
    #   pkg: builtins.elem (lib.getName pkg) config.allowUnfreePackages;
    #
    # # Allow specified insecure packages (identified elsewhere)
    # nixpkgs.config.permittedInsecurePackages = config.allowInsecurePackages;

  };

}
