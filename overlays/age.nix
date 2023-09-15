# Pin age because it is failing to build

inputs: _final: prev: {
  age = prev.age.overrideAttrs (old: { src = inputs.age; });
}
