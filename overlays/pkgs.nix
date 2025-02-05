_final: prev:

let
  lib = prev.lib;
  packages = lib.pipe [
    (lib.filesystem.listFilesRecursive ../pkgs)
    (builtins.filter (name: (lib.hasSuffix "package.nix" name)))
    (builtins.map (package: prev.callPackage package))
  ];
in

{

  loadkey = prev.callPackage ../pkgs/tools/misc/loadkey.nix { };
  aws-ec2 = prev.callPackage ../pkgs/tools/misc/aws-ec2 { };
  docker-cleanup = prev.callPackage ../pkgs/tools/misc/docker-cleanup { };
  nmasur-neovim = prev.callPackage ../pkgs/applications/editors/neovim/nmasur/neovim { };
}
