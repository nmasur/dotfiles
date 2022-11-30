{ pkgs, dsl, ... }: {

  plugins = [ pkgs.vimPlugins.nvim-tree-lua pkgs.vimPlugins.nvim-web-devicons ];

  # Disable netrw eagerly
  # https://github.com/kyazdani42/nvim-tree.lua/commit/fb8735e96cecf004fbefb086ce85371d003c5129
  vim.g = {
    loaded = 1;
    loaded_netrwPlugin = 1;
  };

  setup.nvim-tree = {
    disable_netrw = true;
    hijack_netrw = true;
    update_focused_file = {
      enable = true;
      update_cwd = true;
      ignore_list = { };
    };
    diagnostics = {
      enable = true;
      icons = {
        hint = "";
        info = "";
        warning = "";
        error = "";
      };
    };
    renderer = {
      icons = {
        glyphs = {
          git = {
            unstaged = "~";
            staged = "+";
            unmerged = "";
            renamed = "➜";
            deleted = "";
            untracked = "?";
            ignored = "◌";
          };
        };
      };
    };
    view = {
      width = 30;
      hide_root_folder = false;
      side = "left";
      mappings = {
        custom_only = false;
        list = [
          {
            key = [ "l" "<CR>" "o" ];
            cb = dsl.rawLua
              "require('nvim-tree.config').nvim_tree_callback('edit')";
          }
          {
            key = "h";
            cb = dsl.rawLua
              "require('nvim-tree.config').nvim_tree_callback('close_node')";
          }
          {
            key = "v";
            cb = dsl.rawLua
              "require('nvim-tree.config').nvim_tree_callback('vsplit')";
          }
        ];
      };
      number = false;
      relativenumber = false;
    };
  };

  lua = ''
    vim.keymap.set("n", "<Leader>e", ":NvimTreeFindFileToggle<CR>", { silent = true })
  '';

}
