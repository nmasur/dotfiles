{
  config,
  lib,
  modulesPath,
  ...
}:
{

  # options.iso.enable = lib.mkEnableOption "Enable creating as an ISO.";
  #
  # imports = [ "${toString modulesPath}/installer/cd-dvd/iso-image.nix" ];

  # config = lib.mkIf config.iso.enable {
  #
  #   # EFI booting
  #   isoImage.makeEfiBootable = true;
  #
  #   # USB booting
  #   isoImage.makeUsbBootable = true;
  #
  # };
}
