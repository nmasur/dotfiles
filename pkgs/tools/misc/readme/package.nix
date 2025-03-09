{ pkgs, ... }:

pkgs.writeShellScriptBin "readme" ''
  ${pkgs.glow}/bin/glow --pager ${builtins.toString ../../../../README.md}
''
