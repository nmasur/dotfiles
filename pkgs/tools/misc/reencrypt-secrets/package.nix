{ pkgs, ... }:

# nix run github:nmasur/dotfiles#reencrypt-secrets ./private

pkgs.writeShellScriptBin "reencrypt-secrets" ''
  if [ $# -eq 0 ]; then
    echo "Must provide directory to reencrypt."
    exit 1
  fi
  encrypted=$1
  find "''${1}" -type f -name "*.age" | while IFS= read -r encryptedfile; do
    tmpfile=$(mktemp)
    echo "Decrypting ''${encryptedfile}..."
    ${pkgs.age}/bin/age --decrypt \
      --identity ~/.ssh/id_ed25519 $encryptedfile > $tmpfile
    echo "Encrypting ''${encryptedfile}..."
    ${pkgs.age}/bin/age --encrypt --armor --recipients-file ${builtins.toString ../../../../misc/public-keys} $tmpfile > $encryptedfile
    rm $tmpfile
  done
  echo "Finished."
''
