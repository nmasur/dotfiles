inputs: _final: prev: {

  stu = prev.rustPlatform.buildRustPackage {
    pname = "stu";
    version = "0.5.0";
    src = inputs.stu;
    cargoHash = "sha256-gUolS7HXkTddxDWDGir4YC+2tJjgB/CCQC49SSRaR6U=";
    buildInputs =
      if prev.stdenv.isDarwin then
        [
          prev.darwin.apple_sdk.frameworks.CoreGraphics
          prev.darwin.apple_sdk.frameworks.AppKit
        ]
      else
        [ ];
  };
}
