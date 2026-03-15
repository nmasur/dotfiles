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
    (final: prev: {
      zellij-switch = inputs.zellij-switch.packages.${prev.stdenv.hostPlatform.system}.default;
    })
    # inputs.helix.overlays.default
  ]
  ++ (importOverlays ../overlays);

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
      config.permittedInsecurePackages = [
        "litestream-0.3.13"
        "electron-36.9.5"
        # Build-time-only dep of karakeep's frontend; CVEs don't reach
        # the runtime closure. Remove once nixpkgs bumps it.
        "pnpm-9.15.9"
      ];
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
      }
      // specialArgs;
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
        inputs.nix-index-database.nixosModules.default
        inputs.disko.nixosModules.disko
        inputs.wsl.nixosModules.wsl
        { imports = (nixFiles ../platforms/nixos); }
        module
        {
          home-manager = {
            extraSpecialArgs = {
              inherit colorscheme;
            }
            // specialArgs;
          }
          // homeModule.home-manager;
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
        inputs.nix-index-database.darwinModules.nix-index
        inputs.mac-app-util.darwinModules.default
        {
          imports = (nixFiles ../platforms/nix-darwin);
          nixpkgs.pkgs = pkgsBySystem.${system};
        }
        # Home Manager is intentionally NOT activated here. It is managed
        # standalone via `nh home switch` (see homeConfigurations, extracted
        # from the host module's `home-manager.users`). Strip that attr so
        # darwin-rebuild doesn't also activate a second, divergent HM
        # generation with different store paths (useUserPackages puts packages
        # in /etc/profiles/per-user vs. ~/.nix-profile standalone) -- that
        # mismatch broke the prompt after every darwin-rebuild until the next
        # `nh home switch`.
        (builtins.removeAttrs module [ "home-manager" ])
      ];
    };

  generatorOptions = {
    amazon = {
      aws.enable = true;
    };
    iso = {
      nmasur.profiles.wsl.enable = lib.mkForce false;
      boot.loader.grub.enable = lib.mkForce false;
    };
    qcow-efi = {
      nmasur.profiles.wsl.enable = lib.mkForce false;
      boot.loader.grub.enable = lib.mkForce false;
      fileSystems."/boot".device = lib.mkForce "/dev/disk/by-label/ESP";
    };
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
      pkgs = pkgsBySystem.${system};
      modules = [
        inputs.home-manager.nixosModules.home-manager
        inputs.nix-index-database.homeModules.default
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
            }
            // specialArgs;
          }
          // homeModule.home-manager;
        }
      ];
      specialArgs = {
      }
      // specialArgs;
    };

}
