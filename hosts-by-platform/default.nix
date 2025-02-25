# Return a list of all hosts

nixpkgs:

let
  inherit (nixpkgs) lib;
in

{
  # darwin-hosts = import ./darwin;
  aarch64-darwin-hosts = lib.pipe (lib.filesystem.listFilesRecursive ./aarch64-darwin) [
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
  aarch64-linux-hosts = lib.pipe (lib.filesystem.listFilesRecursive ./aarch64-linux) [
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
  x86_64-linux-hosts = lib.pipe (lib.filesystem.listFilesRecursive ./x86_64-linux) [
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
