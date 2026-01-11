{ pkgs, ... }:

pkgs.mkShell {
  name = "dotfiles-devshell";
  buildInputs = with pkgs; [
    git
    stylua
    nixfmt
    shfmt
    shellcheck
  ];
}
