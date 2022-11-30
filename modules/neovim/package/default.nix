# { inputs, globals, extraConfig ? [ ], ... }:
#
# let
#
#   pkgs = import inputs.nixpkgs {
#     system = inputs.system;
#     overlays = [
#       (import ./modules/neovim/plugins-overlay.nix inputs)
#       inputs.nix2vim.overlay
#     ];
#   };
#
# in pkgs.neovimBuilder {
#   package = pkgs.neovim-unwrapped;
#   imports = [
#     ./modules/neovim/plugins/bufferline.nix
#     ./modules/neovim/plugins/completion.nix
#     ./modules/neovim/plugins/gitsigns.nix
#     ./modules/neovim/plugins/lsp.nix
#     ./modules/neovim/plugins/misc.nix
#     ./modules/neovim/plugins/statusline.nix
#     ./modules/neovim/plugins/syntax.nix
#     ./modules/neovim/plugins/telescope.nix
#     ./modules/neovim/plugins/toggleterm.nix
#     ./modules/neovim/plugins/tree.nix
#   ] ++ extraConfig;
# }

{ pkgs, colors ? { }, ... }:

pkgs.neovimBuilder {
  package = pkgs.neovim-unwrapped;
  imports = [
    ../config/bufferline.nix
    ../config/completion.nix
    ../config/gitsigns.nix
    ../config/lsp.nix
    ../config/misc.nix
    ../config/statusline.nix
    ../config/syntax.nix
    ../config/telescope.nix
    ../config/toggleterm.nix
    ../config/tree.nix
    colors
  ];
}
