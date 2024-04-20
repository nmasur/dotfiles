{ pkgs, ... }:
{

  config = {

    # MacOS-specific settings for Fish
    programs.fish.useBabelfish = true;
    programs.fish.babelfishPackage = pkgs.babelfish;
  };
}
