# Adopted from here: https://github.com/DieracDelta/vimconfig/blob/801b62dd56cfee59574639904a6c95b525725f66/plugins.nix

inputs: final: prev:

let

  # Use nixpkgs vimPlugin but with source directly from plugin author
  withSrc = pkg: src: pkg.overrideAttrs (_: { inherit src; });

  # Package plugin
  plugin = pname: src:
    prev.vimUtils.buildVimPluginFrom2Nix {
      inherit pname src;
      version = "master";
    };

in {

  nil = inputs.nil.packages.${prev.system}.nil;

  nvim-lspconfig =
    (withSrc prev.vimPlugins.nvim-lspconfig inputs.nvim-lspconfig);
  cmp-nvim-lsp = (withSrc prev.vimPlugins.cmp-nvim-lsp inputs.cmp-nvim-lsp);
  cmp-buffer = (withSrc prev.vimPlugins.cmp-buffer inputs.cmp-buffer);
  plenary-nvim = (withSrc prev.vimPlugins.plenary-nvim inputs.plenary-nvim);
  null-ls-nvim = (withSrc prev.vimPlugins.null-ls-nvim inputs.null-ls-nvim);
  vim-surround = (withSrc prev.vimPlugins.vim-surround inputs.vim-surround);
  vim-repeat = (withSrc prev.vimPlugins.vim-repeat inputs.vim-repeat);
  comment-nvim = (withSrc prev.vimPlugins.comment-nvim inputs.comment-nvim);
  impatient-nvim =
    (withSrc prev.vimPlugins.impatient-nvim inputs.impatient-nvim);
  nvim-treesitter =
    (withSrc prev.vimPlugins.nvim-treesitter inputs.nvim-treesitter);
  telescope-nvim =
    (withSrc prev.vimPlugins.telescope-nvim inputs.telescope-nvim);
  telescope-project-nvim = (withSrc prev.vimPlugins.telescope-project-nvim
    inputs.telescope-project-nvim);
  toggleterm-nvim =
    (withSrc prev.vimPlugins.toggleterm-nvim inputs.toggleterm-nvim);
  gitsigns-nvim = (withSrc prev.vimPlugins.gitsigns-nvim inputs.gitsigns-nvim);
  lualine-nvim = (withSrc prev.vimPlugins.lualine-nvim inputs.lualine-nvim);
  nvim-web-devicons =
    (withSrc prev.vimPlugins.nvim-web-devicons inputs.nvim-web-devicons);
  bufferline-nvim =
    (withSrc prev.vimPlugins.bufferline-nvim inputs.bufferline-nvim);
  vim-bbye = (withSrc prev.vimPlugins.vim-bbye inputs.vim-bbye);
  nvim-tree-lua = (withSrc prev.vimPlugins.nvim-tree-lua inputs.nvim-tree-lua);

  # Packaging plugins with Nix
  # comment-nvim = plugin "comment-nvim" comment-nvim-src;
  # plenary-nvim = plugin "plenary-nvim" plenary-nvim-src;

}
