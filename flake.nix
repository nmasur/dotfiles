{
  description = "My system";

  # Other flakes that we want to pull from
  inputs = {

    # Used for system packages
    nixpkgs.url = "github:nixos/nixpkgs/nixos-unstable";

    # Used for user packages
    home-manager = {
      url = "github:nix-community/home-manager/master";
      inputs.nixpkgs.follows =
        "nixpkgs"; # Use system packages list where available
    };

    # Community packages; used for Firefox extensions
    nur.url = "github:nix-community/nur";

  };

  outputs = { self, nixpkgs, home-manager, nur }:
    let

      # Global configuration for my systems
      globals = {
        user = "noah";
        fullName = "Noah Masur";
        passwordHash =
          "$6$J15o3OLElCEncVB3$0FW.R7YFBMgtBp320kkZO.TdKvYDLHmnP6dgktdrVYCC3LUvzXj0Fj0elR/fXo9geYwwWi.EAHflCngL5T.3g/";
        gitEmail = "7386960+nmasur@users.noreply.github.com";
        gui = {
          colorscheme = (import ./modules/colorscheme/gruvbox);
          wallpaper = ../../../downloads/nix.jpg;
          gtkTheme = "Adwaita-dark";
        };
      };

    in {

      # Define my systems
      # You can load it from an empty system with:
      # nix-shell -p nixFlakes
      # sudo nixos-rebuild switch --flake github:nmasur/dotfiles#desktop
      nixosConfigurations = {
        desktop =
          import ./hosts/desktop { inherit nixpkgs home-manager nur globals; };
      };

      # Used to run commands and editing in this repo
      devShells.x86_64-linux =
        let pkgs = import nixpkgs { system = "x86_64-linux"; };
        in {
          default = pkgs.mkShell {
            buildInputs = with pkgs; [ git stylua nixfmt shfmt shellcheck ];
          };
        };

    };
}
