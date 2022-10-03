{ pkgs, ... }: {

  type = "app";

  program = builtins.toString (pkgs.writeShellScript "loadkey" ''
    ${pkgs.melt}/bin/melt restore ~/.ssh/id_ed25519
  '');

}
