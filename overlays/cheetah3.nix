_inputs: _final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (_pyfinal: pyprev: {
      cheetah3 = pyprev.cheetah3.overridePythonAttrs (_old: {
        dontCheckPythonMetadata = true;
      });
    })
  ];
}
