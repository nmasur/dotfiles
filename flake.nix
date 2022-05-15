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
          "$6$PZYiMGmJIIHAepTM$Wx5EqTQ5GApzXx58nvi8azh16pdxrN6Qrv1wunDlzveOgawitWzcIxuj76X9V868fsPi/NOIEO8yVXqwzS9UF.";
        gitEmail = "7386960+nmasur@users.noreply.github.com";
        mailServer = "noahmasur.com";
        gui = {
          colorscheme = (import ./modules/colorscheme/gruvbox);
          wallpaper = ./media/wallpaper/road.jpg;
          gtk.theme = { name = "Adwaita-dark"; };
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
