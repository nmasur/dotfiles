# Pin age because it is failing to build
# https://github.com/NixOS/nixpkgs/pull/265753

inputs: _final: prev: {
  age = prev.age.overrideAttrs (old: {
    src = inputs.age;
    doCheck = false; # https://github.com/FiloSottile/age/issues/517
  });
}
