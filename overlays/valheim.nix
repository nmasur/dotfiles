_inputs: final: prev:

{
  fetchValheimThunderstoreMod =
    {
      owner,
      name,
      version,
      hash,
    }:
    let
      depString = "${owner}-${name}";
    in
    prev.fetchzip {
      inherit version hash;
      name = "valheim-thunderstore-${depString}";
      url = "https://thunderstore.io/package/download/${owner}/${name}/${version}/";
      extension = "zip";
      stripRoot = false;
    };
}
// prev.lib.optionalAttrs (prev.stdenv.hostPlatform.isLinux && prev.stdenv.hostPlatform.isx86_64) {
  valheim-server = final.nmasur.valheim-server;
  valheim-server-unwrapped = final.nmasur.valheim-server.unwrapped;
}
