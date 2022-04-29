{
  description = "My system";

  inputs = {
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows = "nixpkgs";
    };

  };

  outputs = { self, nixpkgs, home-manager }:
    let
      # Set the system type globally (changeme)
      system = "x86_64-linux";

      # Gather the Nix packages
      pkgs = import nixpkgs {
        inherit system;
        config.allowUnfree = true;
      };

      user = "noah";
      fullName = "Noah Masur";
      font = {
        package = pkgs.victor-mono;
        name = "Victor Mono";
      };

    in {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            gui = true;
            inherit user fullName font;
          };
          modules = [
            home-manager.nixosModules.home-manager
            ./nixos/configuration.nix
            ./nixos/hardware-configuration.nix
            ./nixos/home.nix
            ./modules/system/timezone.nix
            ./modules/system/doas.nix
            ./modules/gaming
            ./modules/services/keybase.nix
            ./modules/applications/firefox.nix
            ./modules/applications/alacritty.nix
            ./modules/shell/fish.nix
            ./modules/shell/utilities.nix
            ./modules/shell/git.nix
            ./modules/shell/github.nix
            ./modules/editor/neovim.nix
          ];
        };
      };

      devShells.x86_64-linux.default = pkgs.mkShell {
        buildInputs = with pkgs; [ stylua nixfmt shfmt shellcheck ];
      };

    };
}
