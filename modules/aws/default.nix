{ ... }:
{
  # AWS settings require this
  permitRootLogin = "prohibit-password";

  # Make sure disk size is large enough
  # https://github.com/nix-community/nixos-generators/issues/150
  amazonImage.sizeMB = 16 * 1024;
}
