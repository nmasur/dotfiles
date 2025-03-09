{ pkgs, ... }:

pkgs.mkShell {
  name = "dotfiles-devshell";
  buildInputs = with pkgs; [
    git
    stylua
    nixfmt-rfc-style
    shfmt
    shellcheck
  ];
}
