{ lib, ... }:
{
  imports = lib.filesystem.listFilesRecursive ./.;
}
