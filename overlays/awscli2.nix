inputs: _final: prev: {

  awscli2 = prev.awscli2.overrideAttrs (
    finalAttrs: previousAttrs: {
      src = prev.fetchFromGitHub {
        owner = "aws";
        repo = "aws-cli";
        rev = "2.31.27";
        hash = "sha256-NnAEdbIZVri9Bi0KBlcZIVox+LbuD0/hBdtYB/UFHeo=";
      };
      disabledTestPaths = previousAttrs.disabledTestPaths ++ [
        "tests/unit/customizations"
      ];
    }
  );
}
