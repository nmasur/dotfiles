{ pkgs, ... }: {

  type = "app";

  program = "${
      (import ../modules/common/neovim/package {
        inherit pkgs;
        colors =
          import ../colorscheme/gruvbox/neovim-gruvbox.nix { inherit pkgs; };
      })
    }/bin/nvim";

}
