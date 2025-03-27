{ pkgs, ... }:

pkgs.writeShellScriptBin "encrypt-secret" ''
  printf "\nEnter the secret data to encrypt for all hosts...\n\n" 1>&2
  read -p "Secret: " secret
  printf "\nEncrypting...\n\n" 1>&2
  tmpfile=$(mktemp)
  echo "''${secret}" > ''${tmpfile}
  ${pkgs.age}/bin/age --encrypt --armor --recipients-file ${builtins.toString ../../../../misc/public-keys} $tmpfile
  rm $tmpfile
''
