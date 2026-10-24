# Upstream pyopenjtalk-plus has a test (test_run_njd_from_mecab_invalid_input_should_not_break_next_call)
# that asserts the exact TypeError exception string "must be str", which changed to "Expected str, got int"
# under Python 3.14 / Cython.
_inputs: _final: prev: {
  pythonPackagesExtensions = prev.pythonPackagesExtensions ++ [
    (_pyfinal: pyprev: {
      pyopenjtalk-plus = pyprev.pyopenjtalk-plus.overridePythonAttrs (old: {
        disabledTests = (old.disabledTests or [ ]) ++ [
          "test_run_njd_from_mecab_invalid_input_should_not_break_next_call"
        ];
      });
    })
  ];
}
