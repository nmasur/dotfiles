{ pkgs, ... }: rec {

  default = readme;

  # Format and install from nothing
  installer = import ./installer.nix { inherit pkgs; };

  # Display the readme for this repository
  readme = import ./readme.nix { inherit pkgs; };

  # Load the SSH key for this machine
  loadkey = import ./loadkey.nix { inherit pkgs; };

  # Encrypt secret for all machines
  encrypt-secret = import ./encrypt-secret.nix { inherit pkgs; };

  # Re-encrypt secrets for all machines
  reencrypt-secrets = import ./reencrypt-secrets.nix { inherit pkgs; };

  # Connect machine metrics to Netdata Cloud
  netdata = import ./netdata-cloud.nix { inherit pkgs; };

}
