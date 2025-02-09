_final: prev:

let
  listToAttrsByField =
    field: list:
    builtins.listToAttrs (
      map (v: {
        name = v.${field};
        value = v;
      }) list
    );
  lib = prev.lib;
  packagesDirectory = lib.filesystem.listFilesRecursive ../pkgs;
  packages = lib.pipe packagesDirectory [
    # Get only files called package.nix
    (builtins.filter (name: lib.hasSuffix "package.nix"))
    # Apply callPackage to create a derivation
    (builtins.map prev.callPackage)
    # Convert the list to an attrset
    (listToAttrsByField "name")
  ];
in

packages
