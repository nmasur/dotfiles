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

  outputs = { self, nixpkgs, darwin, home-manager, nur, wallpapers }:

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

      # You can load it from any NixOS system with:
      # nix-shell -p nixFlakes
      # sudo nixos-rebuild switch --flake github:nmasur/dotfiles#desktop
      nixosConfigurations = {
        desktop = import ./hosts/desktop {
          inherit nixpkgs home-manager nur globals wallpapers;
        };
      };

      darwinConfigurations = {
        macbook = import ./hosts/macbook {
          inherit nixpkgs darwin home-manager nur globals;
        };
      };

      # You can partition, format, and install from a live disk with:
      # nix-shell -p nixFlakes
      # nix run github:nmasur/dotfiles#installer -- nvme0n1 desktop
      # Will erase drives; use at your own risk!
      apps = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          installer = import ./modules/system/installer.nix { inherit pkgs; };
        });

      # Used to run commands and edit files in this repo
      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system; };
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ git stylua nixfmt shfmt shellcheck ];
          };
        });

    };
}
