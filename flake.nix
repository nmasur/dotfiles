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
      identity = {
        user = "noah";
        name = "Noah Masur";
        hostname = "nixos";
        gitEmail = "7386960+nmasur@users.noreply.github.com";
      };
      gui = {
        enable = false;
        font = {
          package = "victor-mono";
          name = "Victor Mono";
        };
        gtkTheme = "Adwaita-dark";
      };
    in {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = {
            gui = gui // { enable = true; };
            inherit identity;
          };
          modules = [
            home-manager.nixosModules.home-manager
            ./nixos/hardware-configuration.nix
            ./nixos/configuration.nix
            ./nixos/home.nix
            ./modules/desktop
            ./modules/hardware
            ./modules/system
            ./modules/shell
            ./modules/gaming
            ./modules/services/keybase.nix
            ./modules/applications/firefox.nix
            ./modules/applications/alacritty.nix
            ./modules/applications/media.nix
            ./modules/applications/1password.nix
            ./modules/applications/discord.nix
            ./modules/editor/neovim.nix
          ];
        };
      };
      devShells.x86_64-linux =
        let pkgs = import nixpkgs { system = "x86_64-linux"; };
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ stylua nixfmt shfmt shellcheck ];
          };
        };

    };
}
