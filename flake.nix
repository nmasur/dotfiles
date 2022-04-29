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
      hostname = "nixos";
      gtkTheme = "Adwaita-dark";

    in {
      nixosConfigurations = {
        desktop = nixpkgs.lib.nixosSystem {
          inherit system;
          specialArgs = {
            gui = true;
            inherit user fullName font hostname gtkTheme;
          };
          modules = [
            home-manager.nixosModules.home-manager
            ./nixos/hardware-configuration.nix
            ./nixos/configuration.nix
            ./nixos/home.nix
            ./modules/desktop/xorg.nix
            ./modules/desktop/i3.nix
            ./modules/desktop/fonts.nix
            ./modules/hardware/boot.nix
            ./modules/hardware/mouse.nix
            ./modules/hardware/keyboard.nix
            ./modules/hardware/monitors.nix
            ./modules/hardware/audio.nix
            ./modules/hardware/networking.nix
            ./modules/system/timezone.nix
            ./modules/system/doas.nix
            ./modules/system/user.nix
            ./modules/gaming
            ./modules/services/keybase.nix
            ./modules/applications/firefox.nix
            ./modules/applications/alacritty.nix
            ./modules/applications/media.nix
            ./modules/applications/1password.nix
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
