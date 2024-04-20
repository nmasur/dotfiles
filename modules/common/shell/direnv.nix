{ config, ... }:
{

  # Enables quickly entering Nix shells when changing directories
  home-manager.users.${config.user}.programs.direnv = {
    enable = true;
    nix-direnv.enable = true;
    config = {
      whitelist = {
        prefix = [ config.dotfilesPath ];
      };
    };
  };

  # programs.direnv.direnvrcExtra = ''
  #   layout_postgres() {
  #       export PGDATA="$(direnv_layout_dir)/postgres"
  #       export PGHOST="$PGDATA"
  #
  #       if [[ ! -d "PGDATA" ]]; then
  #           initdb
  #           cat >> "$PGDATA/postgres.conf" <<- EOF
  #                   listen_addresses = '''
  #                   unix_socket_directories = '$PGHOST'
  #           EOF
  #           echo "CREATE DATABASE $USER;" | postgres --single -E postgres
  #       fi
  #   }
  # '';

  # Prevent garbage collection
  nix.extraOptions = ''
    keep-outputs = true
    keep-derivations = true
  '';
}
