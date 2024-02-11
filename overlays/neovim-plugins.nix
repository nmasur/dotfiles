# Adopted from here: https://github.com/DieracDelta/vimconfig/blob/801b62dd56cfee59574639904a6c95b525725f66/plugins.nix

inputs: _final: prev:

let

  # Use nixpkgs vimPlugin but with source directly from plugin author
  withSrc = pkg: src: pkg.overrideAttrs (_: { inherit src; });

  # Package plugin - for plugins not found in nixpkgs at all
  plugin = pname: src:
    prev.vimUtils.buildVimPlugin {
      inherit pname src;
      version = "master";
    };

in {

  vimPlugins = prev.vimPlugins // {

    nvim-lspconfig =
      withSrc prev.vimPlugins.nvim-lspconfig inputs.nvim-lspconfig-src;
    cmp-nvim-lsp = withSrc prev.vimPlugins.cmp-nvim-lsp inputs.cmp-nvim-lsp-src;
    comment-nvim = withSrc prev.vimPlugins.comment-nvim inputs.comment-nvim-src;
    nvim-treesitter =
      withSrc prev.vimPlugins.nvim-treesitter inputs.nvim-treesitter-src;
    telescope-nvim =
      withSrc prev.vimPlugins.telescope-nvim inputs.telescope-nvim-src;
    telescope-project-nvim = withSrc prev.vimPlugins.telescope-project-nvim
      inputs.telescope-project-nvim-src;
    toggleterm-nvim =
      withSrc prev.vimPlugins.toggleterm-nvim inputs.toggleterm-nvim-src;
    bufferline-nvim =
      withSrc prev.vimPlugins.bufferline-nvim inputs.bufferline-nvim-src;
    nvim-tree-lua =
      withSrc prev.vimPlugins.nvim-tree-lua inputs.nvim-tree-lua-src;
    fidget-nvim = withSrc prev.vimPlugins.fidget-nvim inputs.fidget-nvim-src;
    nvim-lint = withSrc prev.vimPlugins.nvim-lint inputs.nvim-lint-src;

    # Packaging plugins entirely with Nix
    baleia-nvim = plugin "baleia-nvim" inputs.baleia-nvim-src;
    hmts-nvim = plugin "hmts-nvim" inputs.hmts-nvim-src;
    kitty-scrollback-nvim = prev.vimUtils.buildVimPlugin {
      pname = "kitty-scrollback-nvim";
      src = inputs.kitty-scrollback-nvim-src;
      version = "master";
      patches = [ ./kitty-scrollback-nvim.patch ];
    };

  };

}
