_inputs: _final: prev:

let
  # TODO: Remove
  # listToAttrsByField =
  #   field: list:
  #   builtins.listToAttrs (
  #     map (v: {
  #       name = v.${field};
  #       value = v;
  #     }) list
  #   );

  listToAttrsByPnameOrName =
    list:
    builtins.listToAttrs (
      map (v: {
        name = v."pname" or v."name";
        value = v;
      }) list
    );
  lib = prev.lib;
  # packagesDirectory = lib.filesystem.listFilesRecursive ../pkgs;
  # [ package1/package.nix package2/package.nix package2/hello.sh ]
  packages = lib.pipe (lib.filesystem.listFilesRecursive ../pkgs) [
    # Get only files called package.nix
    # [ package1/package.nix package2/package.nix ]
    (builtins.filter (name: lib.hasSuffix "package.nix" name))

    # Apply callPackage to create a derivation
    # Must use final.callPackage to avoid infinite recursion
    # [ package1.drv package2.drv ]
    (builtins.map (name: prev.callPackage name { }))

    # Convert the list to an attrset
    # { package1 = package1.drv, package2 = package2.drv }
    listToAttrsByPnameOrName
  ];
in

{
  nmasur = packages;
}
