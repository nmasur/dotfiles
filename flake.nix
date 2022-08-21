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

    # Wallpapers
    wallpapers = {
      url = "gitlab:exorcist365/wallpapers";
      flake = false;
    };

  };

  outputs = { self, nixpkgs, darwin, wsl, home-manager, nur, wallpapers }:

    let

      # Global configuration for my systems
      globals = {
        user = "noah";
        fullName = "Noah Masur";
        gitEmail = "7386960+nmasur@users.noreply.github.com";
        mailServer = "noahmasur.com";
        dotfilesRepo = "https://github.com/nmasur/dotfiles";
      };

      # System types to support.
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in {

      nixosConfigurations = {
        desktop = import ./hosts/desktop {
          inherit nixpkgs home-manager nur globals wallpapers;
        };
        wsl = import ./hosts/wsl { inherit nixpkgs wsl home-manager globals; };
      };

      darwinConfigurations = {
        macbook = import ./hosts/macbook {
          inherit nixpkgs darwin home-manager nur globals;
        };
      };

      apps = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in rec {
          default = readme;

          # Format and install from nothing
          installer = import ./apps/installer.nix { inherit pkgs; };

          # Display the readme for this repository
          readme = import ./apps/readme.nix { inherit pkgs; };

        });

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
