_inputs: _final: prev: {

  kubernetes-helm = prev.kubernetes-helm.overrideAttrs (_old: {
    doCheck = false;
  });

}
