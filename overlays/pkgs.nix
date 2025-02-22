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

  listToAttrsByPnameOrName =
    list:
    builtins.listToAttrs (
      map (v: {
        name = v."pname" ? v."name";
        value = v;
      }) list
    );
  lib = prev.lib;
  # packagesDirectory = lib.filesystem.listFilesRecursive ../pkgs;
  packages = lib.pipe (lib.filesystem.listFilesRecursive ../pkgs) [
    # Get only files called package.nix
    (builtins.filter (name: lib.hasSuffix "package.nix" name))
    # Apply callPackage to create a derivation
    (builtins.map (name: prev.callPackage name { }))
    # Convert the list to an attrset
    listToAttrsByPnameOrName
  ];
in

packages
