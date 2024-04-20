{ pkgs, ... }:
{

  type = "app";

  program = builtins.toString (
    pkgs.writeShellScript "loadkey" ''
      printf "\nEnter the seed phrase for your SSH key...\n"
      printf "\nThen press ^D when complete.\n\n"
      mkdir -p ~/.ssh/
      ${pkgs.melt}/bin/melt restore ~/.ssh/id_ed25519
      printf "\n\nContinuing activation.\n\n"
    ''
  );
}
