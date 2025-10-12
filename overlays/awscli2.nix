inputs: _final: prev: {

  awscli2 = prev.awscli2.overrideAttrs (
    finalAttrs: previousAttrs: {
      disabledTestPaths = previousAttrs.disabledTestPaths ++ [
        "tests/unit/customizations"
      ];
    }
  );
}
