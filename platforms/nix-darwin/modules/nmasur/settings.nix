{ lib, ... }:

{
  options.nmasur.settings = {
    username = lib.mkOption {
      type = lib.types.str;
      description = "Primary username for the system";
    };
    fullName = lib.mkOption {
      type = lib.types.str;
      description = "Human readable name of the user";
    };
  };
}
