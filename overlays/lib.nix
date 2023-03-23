_final: prev: {
  extraLib = prev.lib // {

    # Quickly package shell scripts with their dependencies
    # From https://discourse.nixos.org/t/how-to-create-a-script-with-dependencies/7970/6
    mkScript = { name, file, env ? [ ] }:
      prev.pkgs.writeScriptBin name ''
        for i in ${prev.lib.concatStringsSep " " env}; do
          export PATH="$i/bin:$PATH"
        done

        exec ${prev.pkgs.bash}/bin/bash ${file} $@
      '';
  };

}
