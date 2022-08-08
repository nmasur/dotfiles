{ pkgs, ... }: {

  type = "app";

  program = builtins.toString (pkgs.writeShellScript "readme" ''
    #!${pkgs.stdenv.shell}

    ${pkgs.glow}/bin/glow ${builtins.toString ../README.md}
  '');

}
