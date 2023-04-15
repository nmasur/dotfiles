{ pkgs, ... }: {

  type = "app";

  program = "${
      (import ../modules/common/neovim/package {
        inherit pkgs;
        colors = (import ../colorscheme/gruvbox).dark;
      })
    }/bin/nvim";

}
