# Fix: Volnoti binary not found
# Broken by https://github.com/nix-community/home-manager/pull/5725/commits/98bf8de65dc1ed12c6443b18f6f24d36e9c438d6
_final: prev: {
  volnoti = prev.volnoti.overrideAttrs (oldAttrs: {
    meta.mainProgram = "volnoti";
  });
}
