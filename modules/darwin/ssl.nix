{ config, pkgs, ... }: {

  # security.pki.certificateFiles = [
  #   "${pkgs.cacert}/etc/ssl/certs/ca-bundle.crt"
  #   (builtins.toString ../work/nixos-org-certs.crt)
  # ];

  security.pki.certificates =
    [ (builtins.readFile ../work/nixos-org-certs.crt) ];

}
