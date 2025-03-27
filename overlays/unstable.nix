# Include unstable packages
# Adapted from https://github.com/PsychoLlama/dotfiles/blob/dd41f8c60fdc85868dbd7d88cf933348b497dcf0/lib/overlays/latest-packages.nix

inputs: _final: prev: {
  # Provides `pkgs.unstable`.
  unstable = import inputs.nixpkgs {
    inherit (prev) system config;
    overlays = [
      # inputs.self.overlays.vim-plugins
    ];
  };
}
