# Return a list of all overlays

inputs:

let
  lib = inputs.nixpkgs.lib;
in

lib.pipe (lib.filesystem.listFilesRecursive ./.) [
  # Get only files ending in .nix
  (builtins.filter (name: lib.hasSuffix ".nix" name))
  # Remove this file
  (builtins.filter (name: name != ./default.nix))
  # Import each overlay file
  (map (file: (import file) inputs))
]
