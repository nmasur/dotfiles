_final: prev:

{
  loadkey = prev.callPackage ../pkgs/tools/misc/loadkey.nix;
  aws-ec2 = prev.callPackage ../pkgs/tools/misc/aws-ec2/;
  docker-cleanup = prev.callPackage ../pkgs/tools/misc/docker-cleanup/;
}
