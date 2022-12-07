{ pkgs, ... }: rec {

  default = {
    type = "app";
    program = builtins.toString (pkgs.writeShellScript "default" ''
      ${pkgs.gum}/bin/gum style --margin "1 2" --padding "0 2" --foreground "15" --background "55" "Options"
      ${pkgs.gum}/bin/gum format --type=template -- '  {{ Italic "Run with" }} {{ Color "15" "69" " nix run github:nmasur/dotfiles#" }}{{ Color "15" "62" "someoption" }}{{ Color "15" "69" " " }}.'
      echo ""
      echo ""
      ${pkgs.gum}/bin/gum format --type=template -- \
          '  • {{ Color "15" "57" " readme " }} {{ Italic "Documentation for this repository." }}' \
          '  • {{ Color "15" "57" " rebuild " }} {{ Italic "Switch to this configuration." }}' \
          '  • {{ Color "15" "57" " installer " }} {{ Italic "Format and install from nothing." }}' \
          '  • {{ Color "15" "57" " neovim " }} {{ Italic "Test out the Neovim package." }}' \
          '  • {{ Color "15" "57" " loadkey " }} {{ Italic "Load an ssh key for this machine using melt." }}' \
          '  • {{ Color "15" "57" " encrypt-secret " }} {{ Italic "Encrypt a secret for all machines." }}' \
          '  • {{ Color "15" "57" " reencrypt-secrets " }} {{ Italic "Reencrypt all secrets when new machine is added." }}' \
          '  • {{ Color "15" "57" " netdata " }} {{ Italic "Connect a machine to Netdata cloud." }}'
      echo ""
      echo ""
    '');
  };

  # Format and install from nothing
  installer = import ./installer.nix { inherit pkgs; };

  # Display the readme for this repository
  readme = import ./readme.nix { inherit pkgs; };

  # Rebuild
  rebuild = {
    type = "app";
    program = builtins.toString (pkgs.writeShellScript "rebuild" ''
      echo ${pkgs.system}
      echo ${if pkgs.stdenv.isDarwin then "darwin" else "linux"}
    '');
  };

  # Load the SSH key for this machine
  loadkey = import ./loadkey.nix { inherit pkgs; };

  # Encrypt secret for all machines
  encrypt-secret = import ./encrypt-secret.nix { inherit pkgs; };

  # Re-encrypt secrets for all machines
  reencrypt-secrets = import ./reencrypt-secrets.nix { inherit pkgs; };

  # Connect machine metrics to Netdata Cloud
  netdata = import ./netdata-cloud.nix { inherit pkgs; };

  # Run neovim as an app
  neovim = {
    type = "app";
    program = "${
        (import ../modules/neovim/package {
          inherit pkgs;
          colors = import ../modules/colorscheme/gruvbox/neovim-gruvbox.nix {
            inherit pkgs;
          };
        })
      }/bin/nvim";
  };

  nvim = neovim;

}
