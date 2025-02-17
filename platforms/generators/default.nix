{ lib, ... }:
{
  imports = lib.pipe (lib.filesystem.listFilesRecursive ./.) [
    # Get only files ending in .nix
    (builtins.filter (name: lib.hasSuffix ".nix" name))
    # Remove this file
    (builtins.filter (name: name != ./default.nix))
  ];
}
