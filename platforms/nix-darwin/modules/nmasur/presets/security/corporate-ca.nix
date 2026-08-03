{
  config,
  lib,
  ...
}:

let
  cfg = config.nmasur.presets.security.corporateCa;
in

{

  options.nmasur.presets.security.corporateCa = {

    enable = lib.mkEnableOption "trusting a corporate MITM root CA for TLS interception";

    certFile = lib.mkOption {
      type = lib.types.str;
      example = "/etc/ssl/corp-ca/CorpCA.pem";
      description = ''
        Absolute path to a PEM-encoded corporate root CA certificate to add to
        the system trust store.

        Kept out of this (public) repo on purpose, so it points at a file you
        drop on the machine by hand. Passed as a string rather than a Nix path
        literal so pure flake evaluation does not try to read the out-of-repo
        file at eval time; it is read at build time instead (Darwin builds run
        without a sandbox).
      '';
    };

  };

  config = lib.mkIf cfg.enable {

    # Append the corporate root to /etc/ssl/certs/ca-certificates.crt, which
    # both the Nix daemon and (via NIX_SSL_CERT_FILE) client-side flake fetches
    # read. Without this, fetches behind the corporate TLS-intercepting proxy
    # fail with "self-signed certificate in certificate chain".
    security.pki.certificateFiles = [ cfg.certFile ];

  };

}
