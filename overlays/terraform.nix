# Fix for Terraform and Consul on Darwin:
# https://github.com/NixOS/nixpkgs/pull/275534/files
_final: prev: {
  girara = prev.girara.overrideAttrs (old: {
    mesonFlags = [
      "-Ddocs=disabled"
      (prev.lib.mesonEnable "tests"
        ((prev.stdenv.buildPlatform.canExecute prev.stdenv.hostPlatform)
          && (!prev.stdenv.isDarwin)))
    ];
  });
}
