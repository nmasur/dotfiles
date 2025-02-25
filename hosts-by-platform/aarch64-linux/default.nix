# Return a list of all NixOS hosts

{ nixpkgs, ... }:

let
  inherit (nixpkgs) lib;
in

lib.pipe (lib.filesystem.listFilesRecursive ./.) [
  # Get only files ending in default.nix
  (builtins.filter (name: lib.hasSuffix "default.nix" name))
  # Remove this file
  (builtins.filter (name: name != ./default.nix))
  # Import each host function
  map
  (file: {
    name = builtins.baseNameOf (builtins.dirOf file);
    value = import file;
  })
  # Convert to an attrset of hostname -> host function
  (builtins.listToAttrs)
]
