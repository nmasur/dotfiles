{ lib, ... }:

{

  options.hostnames = lib.mkOption {
    type = lib.types.attrsOf lib.types.str;
  };
}
