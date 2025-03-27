{ pkgs, ... }:
{

  # Shows buffers in a VSCode-style tab layout

  plugins = [
    pkgs.vimPlugins.bufferline-nvim
    pkgs.vimPlugins.vim-bbye # Better closing of buffers
    pkgs.vimPlugins.snipe-nvim # Jump between open buffers
  ];
  setup.bufferline = {
    options = {
      diagnostics = "nvim_lsp";
      always_show_bufferline = false;
      separator_style = "slant";
      offsets = [ { filetype = "NvimTree"; } ];
    };
  };
  setup.snipe = { };
  lua = ''
    -- Move buffers
    vim.keymap.set("n", "L", ":BufferLineCycleNext<CR>", { silent = true })
    vim.keymap.set("n", "H", ":BufferLineCyclePrev<CR>", { silent = true })

    -- Kill buffer
    vim.keymap.set("n", "<Leader>x", " :Bdelete<CR>", { silent = true })

    -- Jump to buffer
    vim.keymap.set("n", "gb", require("snipe").open_buffer_menu, { silent = true }) '';
}
