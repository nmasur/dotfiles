inputs:

let
  lib = inputs.nixpkgs.lib;
in

lib
// rec {

  filesInDirectoryWithSuffix =
    directory: suffix:
    lib.pipe (lib.filesystem.listFilesRecursive directory) [
      # Get only files ending in .nix
      (builtins.filter (name: lib.hasSuffix suffix name))
    ];

  # Returns all files ending in .nix for a directory
  nixFiles = directory: filesInDirectoryWithSuffix directory ".nix";

  # Returns all files ending in default.nix for a directory
  defaultFiles = directory: filesInDirectoryWithSuffix directory "default.nix";

  # Imports all files in a directory and passes inputs
  importOverlays =
    directory:
    lib.pipe (nixFiles directory) [
      # Import each overlay file
      (map (file: (import file) inputs))
    ];

  # Import default files as attrset with keys provided by parent directory
  defaultFilesToAttrset =
    directory:
    lib.pipe (defaultFiles directory) [
      # Import each file
      (map (file: {
        name = builtins.baseNameOf (builtins.dirOf file);
        value = import file;
      }))
      # Convert to an attrset of parent dir name -> file
      (builtins.listToAttrs)
    ];

  # [ package1/package.nix package2/package.nix package2/hello.sh ]
  buildPkgsFromDirectoryAndPkgs =
    directory: pkgs:
    lib.pipe (filesInDirectoryWithSuffix directory "package.nix") [

      # Apply callPackage to create a derivation
      # Must use final.callPackage to avoid infinite recursion
      # [ package1.drv package2.drv ]
      (builtins.map (name: pkgs.callPackage name { }))

      # Convert the list to an attrset with keys from pname or name attr
      # { package1 = package1.drv, package2 = package2.drv }
      (builtins.listToAttrs (
        map (v: {
          name = v."pname" or v."name";
          value = v;
        })
      ))
    ];

}
