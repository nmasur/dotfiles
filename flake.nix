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

    # Convert Nix to Neovim config
    nix2vim = {
      url = "github:gytis-ivaskevicius/nix2vim";
      inputs.nixpkgs.follows = "nixpkgs";
    };

    # Nix language server
    nil.url = "github:oxalica/nil";

    # Neovim plugins
    nvim-lspconfig-src = {
      url = "github:neovim/nvim-lspconfig";
      flake = false;
    };
    cmp-nvim-lsp-src = {
      url = "github:hrsh7th/cmp-nvim-lsp";
      flake = false;
    };
    null-ls-nvim-src = {
      url = "github:jose-elias-alvarez/null-ls.nvim";
      flake = false;
    };
    Comment-nvim-src = {
      url = "github:numToStr/Comment.nvim";
      flake = false;
    };
    nvim-treesitter-src = {
      url = "github:nvim-treesitter/nvim-treesitter";
      flake = false;
    };
    telescope-nvim-src = {
      url = "github:nvim-telescope/telescope.nvim";
      flake = false;
    };
    telescope-project-nvim-src = {
      url = "github:nvim-telescope/telescope-project.nvim";
      flake = false;
    };
    toggleterm-nvim-src = {
      url = "github:akinsho/toggleterm.nvim";
      flake = false;
    };
    bufferline-nvim-src = {
      url = "github:akinsho/bufferline.nvim";
      flake = false;
    };
    nvim-tree-lua-src = {
      url = "github:kyazdani42/nvim-tree.lua";
      flake = false;
    };

  };

  outputs = { nixpkgs, ... }@inputs:

    let

      # Global configuration for my systems
      globals = rec {
        user = "noah";
        fullName = "Noah Masur";
        gitName = fullName;
        gitEmail = "7386960+nmasur@users.noreply.github.com";
        mail.server = "noahmasur.com";
        dotfilesRepo = "git@github.com:nmasur/dotfiles";
      };

      # Common overlays to always use
      overlays = [
        inputs.nur.overlay
        inputs.nix2vim.overlay
        (import ./overlays/neovim-plugins.nix inputs)
        (import ./overlays/calibre-web.nix)
      ];

      # System types to support.
      supportedSystems =
        [ "x86_64-linux" "x86_64-darwin" "aarch64-linux" "aarch64-darwin" ];

      # Helper function to generate an attrset '{ x86_64-linux = f "x86_64-linux"; ... }'.
      forAllSystems = nixpkgs.lib.genAttrs supportedSystems;

    in rec {

      nixosConfigurations = {
        tempest = import ./hosts/tempest { inherit inputs globals overlays; };
        hydra = import ./hosts/hydra { inherit inputs globals overlays; };
        flame = import ./hosts/flame { inherit inputs globals overlays; };
        swan = import ./hosts/swan { inherit inputs globals overlays; };
      };

      darwinConfigurations = {
        lookingglass =
          import ./hosts/lookingglass { inherit inputs globals overlays; };
      };

      # For quickly applying local settings with:
      # home-manager switch --flake .#tempest
      homeConfigurations = {
        tempest =
          nixosConfigurations.tempest.config.home-manager.users.${globals.user}.home;
        lookingglass =
          darwinConfigurations.lookingglass.config.home-manager.users."Noah.Masur".home;
      };

      # Package servers into images with a generator
      packages = forAllSystems (system: {

        aws = {
          "${system}" =
            import ./generators/aws { inherit inputs globals system overlays; };
        };

        staff = {
          "${system}" = import ./generators/staff {
            inherit inputs globals system overlays;
          };
        };

        neovim = let pkgs = import nixpkgs { inherit system overlays; };
        in import ./modules/common/neovim/package {
          inherit pkgs;
          colors =
            import ./colorscheme/gruvbox/neovim-gruvbox.nix { inherit pkgs; };
        };

      });

      apps = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system overlays; };
        in import ./apps { inherit pkgs; });

      devShells = forAllSystems (system:
        let pkgs = import nixpkgs { inherit system overlays; };
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
