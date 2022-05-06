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
      globals = {
        user = "noah";
        fullName = "Noah Masur";
        passwordHash =
          "$6$J15o3OLElCEncVB3$0FW.R7YFBMgtBp320kkZO.TdKvYDLHmnP6dgktdrVYCC3LUvzXj0Fj0elR/fXo9geYwwWi.EAHflCngL5T.3g/";
        gitEmail = "7386960+nmasur@users.noreply.github.com";
        gui = {
          colorscheme = (import ./modules/colorscheme/gruvbox);
          wallpaper = ./modules/theme/gruvbox/gray-forest.jpg;
          gtkTheme = "Adwaita-dark";
        };
      };
    in {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          system = "x86_64-linux";
          specialArgs = { };
          modules = [
            globals
            {
              networking.hostName = "desktop";
              gui.enable = true;
            }
            home-manager.nixosModules.home-manager
            ./hosts/desktop/hardware-configuration.nix
            ./modules/common.nix
            ./modules/hardware
            ./modules/system
            ./modules/desktop
            ./modules/shell
            ./modules/gaming
            ./modules/services/keybase.nix
            ./modules/applications/firefox.nix
            ./modules/applications/alacritty.nix
            ./modules/applications/media.nix
            ./modules/applications/1password.nix
            ./modules/applications/discord.nix
            ./modules/editor/neovim.nix
            ./modules/editor/notes.nix
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
