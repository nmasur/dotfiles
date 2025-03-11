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

  # Common overlays to always use
  overlays = [
    inputs.nur.overlays.default
    inputs.nix2vim.overlay
  ] ++ (importOverlays ../overlays);

  # System types to support.
  supportedSystems = [
    "x86_64-linux"
    "x86_64-darwin"
    "aarch64-linux"
    "aarch64-darwin"
  ];

  # Split system types by operating system
  linuxSystems = builtins.filter (lib.hasSuffix "linux") supportedSystems;
  darwinSystems = builtins.filter (lib.hasSuffix "darwin") supportedSystems;

  # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
  forSystems = systems: lib.genAttrs systems;
  forAllSystems = lib.genAttrs supportedSystems;

  # { x86_64-linux = { tempest = { settings = ...; }; }; };
  hosts = forAllSystems (system: defaultFilesToAttrset ../hosts/${system});

  linuxHosts = lib.filterAttrs (name: value: builtins.elem name linuxSystems) hosts;
  darwinHosts = lib.filterAttrs (name: value: builtins.elem name darwinSystems) hosts;

  # { system -> pkgs }
  pkgsBySystem = forAllSystems (
    system:
    import inputs.nixpkgs {
      inherit system overlays;
      config.permittedInsecurePackages = [ "litestream-0.3.13" ];
      config.allowUnfree = true;
    }
  );

  colorscheme = defaultFilesToAttrset ../colorscheme;

  buildHome =
    {
      pkgs,
      modules,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      inherit pkgs;
      modules = modules ++ [
        ../platforms/home-manager
      ];
    };

  buildNixos =
    {
      pkgs,
      modules,
      specialArgs,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit pkgs;
      modules = modules ++ [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.wsl.nixosModules.wsl
        ../platforms/nixos
        {
          home-manager.extraSpecialArgs = {
            hostnames = globals.hostnames;
            inherit colorscheme;
          };
        }
      ];
      specialArgs = {
        hostnames = globals.hostnames;
      };
    };

  buildDarwin =
    { pkgs, modules }:
    inputs.darwin.lib.darwinSystem {
      inherit pkgs;
      modules = modules ++ [
        inputs.home-manager.darwinModules.home-manager
        inputs.mac-app-util.darwinModules.default
        ./platforms/nix-darwin
      ];
    };

}
