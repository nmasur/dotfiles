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
#     ./modules/common/neovim/plugins/bufferline.nix
#     ./modules/common/neovim/plugins/completion.nix
#     ./modules/common/neovim/plugins/gitsigns.nix
#     ./modules/common/neovim/plugins/lsp.nix
#     ./modules/common/neovim/plugins/misc.nix
#     ./modules/common/neovim/plugins/statusline.nix
#     ./modules/common/neovim/plugins/syntax.nix
#     ./modules/common/neovim/plugins/telescope.nix
#     ./modules/common/neovim/plugins/toggleterm.nix
#     ./modules/common/neovim/plugins/tree.nix
#   ] ++ extraConfig;
# }

{
  pkgs,
  colors,
  terraform ? false,
  github ? false,
  kubernetes ? false,
  ...
}:

# Comes from nix2vim overlay:
# https://github.com/gytis-ivaskevicius/nix2vim/blob/master/lib/neovim-builder.nix
pkgs.neovimBuilder {
  package = pkgs.neovim-unwrapped;
  inherit
    colors
    terraform
    github
    kubernetes
    ;
  imports = [
    ../config/align.nix
    ../config/bufferline.nix
    ../config/colors.nix
    ../config/completion.nix
    ../config/gitsigns.nix
    ../config/lsp.nix
    ../config/misc.nix
    ../config/statusline.nix
    ../config/syntax.nix
    ../config/telescope.nix
    ../config/toggleterm.nix
    ../config/tree.nix
  ];
}
