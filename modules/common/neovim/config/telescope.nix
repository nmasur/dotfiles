{ pkgs, dsl, ... }:
{

  # Telescope is a fuzzy finder that can work with different sub-plugins

  plugins = [
    pkgs.vimPlugins.telescope-nvim
    pkgs.vimPlugins.project-nvim
    pkgs.vimPlugins.telescope-fzy-native-nvim
    pkgs.vimPlugins.telescope-file-browser-nvim
    pkgs.vimPlugins.telescope-zoxide
  ];

  setup.telescope = {
    defaults = {
      mappings = {
        i = {
          "['<esc>']" = dsl.rawLua "require('telescope.actions').close";
          "['<C-h>']" = "which_key";
        };
      };
    };
    pickers = {
      find_files = {
        theme = "ivy";
      };
      oldfiles = {
        theme = "ivy";
      };
      buffers = {
        theme = "dropdown";
      };
    };
    extensions = {
      fzy_native = { };
      zoxide = { };
    };
  };

  setup.project_nvim = { };

  lua = builtins.readFile ./telescope.lua;
}
