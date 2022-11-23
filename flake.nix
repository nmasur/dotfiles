{
  description = "My system";

  # Other flakes that we want to pull from
  inputs = {

    # Used for system packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Used for MacOS system config
    darwin = {
      url = "github:/lnl7/nix-darwin/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Used for Windows Subsystem for Linux compatibility
    wsl.url = "github:nix-community/NixOS-WSL";

    # Used for user packages
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows =
        "nixpkgs"; # Use system packages list where available
    };

    # Community packages; used for Firefox extensions
    nur.url = "github:nix-community/nur";

    # Use official Firefox binary for macOS
    firefox-darwin.url = "github:bandithedoge/nixpkgs-firefox-darwin";

    # Wallpapers
    wallpapers = {
      url = "gitlab:exorcist365/wallpapers";
      flake = false;
    };

    # Used to generate NixOS images for other platforms
    nixos-generators = {
      url = "github:nix-community/nixos-generators";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, ... }@inputs:

    let

      # Global configuration for my systems
      globals = rec {
        user = "noah";
        fullName = "Noah Masur";
        gitName = fullName;
        gitEmail = "7386960+nmasur@users.noreply.github.com";
        mailServer = "noahmasur.com";
        dotfilesRepo = "git@github.com:nmasur/dotfiles";
      };

      # System types to support.
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in rec {

      nixosConfigurations = {
        desktop = import ./hosts/desktop { inherit inputs globals; };
        wsl = import ./hosts/wsl { inherit inputs globals; };
        oracle = import ./hosts/oracle { inherit inputs globals; };
      };

      darwinConfigurations = {
        macbook = import ./hosts/macbook { inherit inputs globals; };
      };

      # For quickly applying local settings with:
      # home-manager switch --flake .#desktop
      homeConfigurations = {
        desktop =
          nixosConfigurations.desktop.config.home-manager.users.${globals.user}.home;
        macbook =
          darwinConfigurations.macbook.config.home-manager.users."Noah.Masur".home;
      };

      # Package servers into images with a generator
      packages.aws = nixpkgs.lib.genAttrs [ "x86_64-linux" "aarch64-linux" ]
        (system: {
          "${system}" = import ./hosts/aws { inherit inputs globals system; };
        });

      apps = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in import ./apps { inherit pkgs; });

      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {

          # Used to run commands and edit files in this repo
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ git stylua nixfmt shfmt shellcheck ];
          };

          # Used for cloud and systems development and administration
          devops = pkgs.mkShell {
            buildInputs = with pkgs; [
              git
              terraform
              consul
              vault
              awscli2
              google-cloud-sdk
              ansible
              kubectl
              kubernetes-helm
              kustomize
              fluxcd
            ];
          };

        });

      # Templates for starting other projects quickly
      templates = rec {
        default = basic;
        basic = {
          path = ./templates/basic;
          description = "Basic program template";
        };
        poetry = {
          path = ./templates/poetry;
          description = "Poetry template";
        };
        python = {
          path = ./templates/python;
          description = "Legacy Python template";
        };
        haskell = {
          path = ./templates/haskell;
          description = "Haskell template";
        };
      };

    };
}
