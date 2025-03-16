inputs:

let
  lib = inputs.nixpkgs.lib;
in

lib
// rec {

  # Returns all files in a directory matching a suffix
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

  homeModule = {
    home-manager = {
      # Include home-manager config in NixOS
      sharedModules = nixFiles ../platforms/home-manager;
      # Use the system-level nixpkgs instead of Home Manager's
      useGlobalPkgs = lib.mkDefault true;
      # Install packages to /etc/profiles instead of ~/.nix-profile, useful when
      # using multiple profiles for one user
      useUserPackages = lib.mkDefault true;
    };
  };

  buildHome =
    {
      system,
      module,
      specialArgs,
    }:
    inputs.home-manager.lib.homeManagerConfiguration {
      pkgs = pkgsBySystem.${system};
      modules = [
        { imports = (nixFiles ../platforms/home-manager); }
        module
      ];
      extraSpecialArgs = {
        inherit colorscheme;
      } // specialArgs;
    };

  buildNixos =
    {
      system,
      module,
      specialArgs,
    }:
    inputs.nixpkgs.lib.nixosSystem {
      inherit specialArgs;
      pkgs = pkgsBySystem.${system};
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.wsl.nixosModules.wsl
        { imports = (nixFiles ../platforms/nixos); }
        module
        {
          home-manager = {
            extraSpecialArgs = {
              inherit colorscheme;
            } // specialArgs;
          } // homeModule.home-manager;
        }
      ];
    };

  buildDarwin =
    {
      system,
      module,
      specialArgs,
    }:
    inputs.darwin.lib.darwinSystem {
      inherit system specialArgs;
      modules = [
        inputs.home-manager.darwinModules.home-manager
        inputs.mac-app-util.darwinModules.default
        {
          imports = (nixFiles ../platforms/nix-darwin);
          nixpkgs.pkgs = pkgsBySystem.${system};
        }
        module
        {
          home-manager = {
            extraSpecialArgs = {
              inherit colorscheme;
            } // specialArgs;
          } // homeModule.home-manager;
        }
      ];
    };

  generatorOptions = {
    amazon = {
      aws.enable = true;
    };
    iso = { };
  };

  generateImage =
    {
      system,
      module,
      format,
      specialArgs,
    }:
    inputs.nixos-generators.nixosGenerate {
      inherit system format;
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.disko.nixosModules.disko
        inputs.wsl.nixosModules.wsl
        {
          imports = (nixFiles ../platforms/nixos) ++ (nixFiles ../platforms/generators);
        }
        generatorOptions.${format}
        module
        {
          home-manager = {
            extraSpecialArgs = {
              inherit colorscheme;
            } // specialArgs;
          } // homeModule.home-manager;
        }
      ];
      specialArgs = {
      } // specialArgs;
    };

}
