{ pkgs, ... }:
{

  type = "app";

  program = builtins.toString (
    pkgs.writeShellScript "readme" ''
      ${pkgs.glow}/bin/glow --pager ${builtins.toString ../README.md}
    ''
  );
}
