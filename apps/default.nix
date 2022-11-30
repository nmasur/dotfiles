{ pkgs, ... }: rec {

  default = readme;

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
