{
  config,
  lib,
  ...
}:

{

  options = {

    identityFile = lib.mkOption {
      type = lib.types.path;
      description = "Path containing decryption identity.";
      default = "/Users/${config.nmasur.settings.username}/.ssh/id_ed25519";
    };

  };

}
