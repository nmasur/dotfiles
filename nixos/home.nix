{ pkgs, ... }:

let

  # Import unstable channel (for Neovim 0.5)
  unstable = import <nixos-unstable> { config = { allowUnfree = true; }; };

in

{
  home.packages = with pkgs; [
    firefox
    unzip
    # alacritty
    # unstable.neovim
    tmux
    rsync
    ripgrep
    bat
    fd
    exa
    sd
    jq
    tealdeer
    zoxide
    unstable._1password-gui
  ];

  programs.alacritty = {
    enable = true;
    settings = {
      window = {
        dimensions = {
          columns = 110;
          lines = 30;
        };
        padding = {
          x = 20;
          y = 20;
        };
      };
      scrolling.history = 10000;
      font = {
        size = 15.0;
      };
      key_bindings = [
        {
          key = "F";
          mods = "Super";
          action = "ToggleFullscreen";
        }
        {
          key = "L";
          mods = "Super";
          chars = "\x1F";
        }
      ];
    };
  };

  programs.fish = {
    enable = true;
  };

  home.sessionVariables = {
    EDITOR = "nvim";
  };

  programs.starship = {
    enable = true;
    enableFishIntegration = true;
  };

  programs.fzf = {
    enable = true;
    enableFishIntegration = true;
  };

  # Other configs
  xdg.configFile = {
    "starship.toml".source = ../starship/starship.toml.configlink;
    #"alacritty/alacritty.yml".source = ../alacritty.configlink/alacritty.yml;
    # "nvim/init.lua".source = ../nvim.configlink/init.lua;
  };

  # nixpkgs.overlays = [(
  #   self: super: {
  #     neovim = unstable.neovim;
  #   })
  # ];
  nixpkgs.overlays = [
    (import (builtins.fetchTarball {
      url = https://github.com/nix-community/neovim-nightly-overlay/archive/master.tar.gz;
    }))
  ];

  programs.neovim = {
    enable = true;
    package = pkgs.neovim-nightly;
    vimAlias = true;
    plugins = with pkgs.vimPlugins; [
      fzf-vim
      fzfWrapper
      vim-eunuch
      vim-vinegar
      surround
      commentary
      repeat
      gruvbox-nvim
      nvim-lspconfig
      lsp-colors-nvim
      vim-vsnip
      vim-vsnip-integ
      nvim-compe
      tabular
      vimwiki
      vim-rooter
      lualine-nvim
      nvim-web-devicons
      nvim-treesitter
      vim-fish
      nginx-vim
      vim-terraform
      vim-toml
      vim-helm
      vim-nix
      gitsigns-nvim
      plenary-nvim
      vim-hexokinase
    ];
    extraPackages = with pkgs; [
      nodePackages.pyright
      rust-analyzer
    ];
    extraConfig = ''
      lua << EOF
        ${builtins.readFile ./init.lua}
      EOF
    '';
  };

  # # Neovim config
  # home.file = {
  #   ".config/nvim/init.lua".source = ../nvim.configlink/init.lua;
  # };

  programs.git = {
    enable = true;
    userName = "Noah Masur";
    userEmail = "7386960+nmasur@users.noreply.github.com";
    extraConfig = {
      core = {
        editor = "nvim";
      };
    };
  };
}
