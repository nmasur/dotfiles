# Return an atrset of all colorschemes

nixpkgs:

let
  inherit (nixpkgs) lib;
in

lib.pipe (lib.filesystem.listFilesRecursive ./.) [
  # Get only files ending in default.nix
  (builtins.filter (name: lib.hasSuffix "default.nix" name))
  # Import each colorscheme function
  (map (file: {
    name = builtins.baseNameOf (builtins.dirOf file);
    value = import file;
  }))
  # Convert to an attrset of colorscheme -> colors
  (builtins.listToAttrs)

]
