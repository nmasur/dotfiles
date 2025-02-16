# Return a list of all hosts

nixpkgs:

let
  inherit (nixpkgs) lib;
in

{
  # darwin-hosts = import ./darwin;
  darwin-hosts = lib.pipe (lib.filesystem.listFilesRecursive ./darwin) [
    # Get only files ending in default.nix
    (builtins.filter (name: lib.hasSuffix "default.nix" name))
    # Import each host function
    (map (file: {
      name = builtins.baseNameOf (builtins.dirOf file);
      value = import file;
    }))
    # Convert to an attrset of hostname -> host function
    (builtins.listToAttrs)
  ];
  nixos-hosts = lib.pipe (lib.filesystem.listFilesRecursive ./nixos) [
    # Get only files ending in default.nix
    (builtins.filter (name: lib.hasSuffix "default.nix" name))
    # Import each host function
    (map (file: {
      name = builtins.baseNameOf (builtins.dirOf file);
      value = import file;
    }))
    # Convert to an attrset of hostname -> host function
    (builtins.listToAttrs)
  ];
}
