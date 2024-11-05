{
  config,
  pkgs,
  lib,
  ...
}:

{

  home-manager.users.${config.user} = lib.mkIf pkgs.stdenv.isDarwin {

    home.packages =
      let
        ldap_scheme = "ldaps";
        magic_prefix = "take";
        ldap_port = 3269;
        jq_parse = pkgs.writeShellScriptBin "ljq" ''
          jq --slurp \
            --raw-input 'split("\n\n")|map(split("\n")|map(select(.[0:1]!="#" and length>0)) |select(length > 0)|map(capture("^(?<key>[^:]*:?): *(?<value>.*)") |if .key[-1:.key|length] == ":" then .key=.key[0:-1]|.value=(.value|@base64d) else . end)| group_by(.key) | map({key:.[0].key,value:(if .|length > 1 then [.[].value] else .[].value end)}) | from_entries)' | jq -r 'del(.[].thumbnailPhoto)'
        '';
        ldap_script = pkgs.writeShellScriptBin "ldap" ''
          if ! [ "$LDAP_HOST" ]; then
              echo "No LDAP_HOST specified!"
              exit 1
          fi
          SEARCH_FILTER="$@"
          ldapsearch -LLL \
              -B -o ldif-wrap=no \
              -E pr=5000/prompt \
              -H "${ldap_scheme}://''${LDAP_HOST}:${builtins.toString ldap_port}" \
              -D "${pkgs.lib.toUpper magic_prefix}2\\${pkgs.lib.toLower config.user}" \
              -w "$(${pkgs._1password-cli}/bin/op item get T2 --fields label=password --reveal)" \
              -b "dc=''${LDAP_HOST//./,dc=}" \
              -s "sub" -x "(cn=''${SEARCH_FILTER})" \
              | ${jq_parse}/bin/ljq
        '';
        ldapm_script = pkgs.writeShellScriptBin "ldapm" ''
          if ! [ "$LDAP_HOST" ]; then
              echo "No LDAP_HOST specified!"
              exit 1
          fi
          ${ldap_script}/bin/ldap "$@" | jq '[ .[].memberOf] | add'
        '';
        ldapg_script = pkgs.writeShellScriptBin "ldapg" ''
          if ! [ "$LDAP_HOST" ]; then
              echo "No LDAP_HOST specified!"
              exit 1
          fi
          ${ldap_script}/bin/ldap "$@" | jq '[ .[].member] | add'
        '';
      in
      [
        ldap_script
        ldapm_script
        ldapg_script
        jq_parse
      ];
  };
}
