# Return a list of all templates

{ lib, ... }:

lib.pipe (lib.filesystem.listFilesRecursive ./.) [
  # Get only files ending in default.nix
  (builtins.filter (name: lib.hasSuffix "flake.nix" name))
  # Import each template function
  map
  (file: rec {
    name = builtins.baseNameOf (builtins.dirOf file);
    value = {
      path = builtins.dirOf file;
      description = "${name} template";
    };
  })
  # Convert to an attrset of template name -> template path and description
  (builtins.listToAttrs)
]
