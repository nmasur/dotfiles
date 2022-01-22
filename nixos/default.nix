# This file does nothing but call configuration.nix
# It is required when in a shell.nix environment
{ ... }: {
  imports = [ ./configuration.nix ];
}
