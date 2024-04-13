inputs: _final: prev: {

  ren = prev.rustPlatform.buildRustPackage {
    pname = "ren-find";
    version = "0.0.7";
    src = inputs.ren;
    cargoHash = "sha256-3bI3j2xvNHp4kyLEq/DZvRJBF2rn6pE4n8oXh67edDI=";
  };

  # rep = prev.rustPlatform.buildRustPackage {
  #   pname = "rep-grep";
  #   version = "0.0.7";
  #   src = inputs.rep;
  #   cargoHash = "sha256-GEr3VvQ0VTKHUbW/GFEgwLpQWP2ZhS/4KYjDvfFLgxo=";
  # };
}
