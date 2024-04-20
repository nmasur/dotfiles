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
        magic_number = "2";
        magic_end_seq = "corp";
        magic_prefix = "take";
        ldap_host = "${magic_prefix}${magic_number}.t${magic_number}.${magic_end_seq}";
        ldap_port = 636;
        ldap_dc_1 = "${magic_prefix}${magic_number}";
        ldap_dc_2 = "t${magic_number}";
        ldap_dc_3 = magic_end_seq;
        ldap_script = pkgs.writeShellScriptBin "ldap" ''
          # if ! [ "$LDAP_HOST" ]; then
          #     echo "No LDAP_HOST specified!"
          #     exit 1
          # fi
          SEARCH_FILTER="$@"
          ldapsearch -LLL \
              -B -o ldif-wrap=no \
              -H "${ldap_scheme}://${ldap_host}:${builtins.toString ldap_port}" \
              -D "${pkgs.lib.toUpper magic_prefix}${magic_number}\\${pkgs.lib.toLower config.user}" \
              -w "$(${pkgs._1password}/bin/op item get T${magic_number} --fields label=password)" \
              -b "DC=${ldap_dc_1},DC=${ldap_dc_2},DC=${ldap_dc_3}" \
              -s "sub" -x "(cn=$SEARCH_FILTER)" \
              | jq --slurp \
                  --raw-input 'split("\n\n")|map(split("\n")|map(select(.[0:1]!="#" and length>0)) |select(length > 0)|map(capture("^(?<key>[^:]*:?): *(?<value>.*)") |if .key[-1:.key|length] == ":" then .key=.key[0:-1]|.value=(.value|@base64d) else . end)| group_by(.key) | map({key:.[0].key,value:(if .|length > 1 then [.[].value] else .[].value end)}) | from_entries)' | jq -r 'del(.[].thumbnailPhoto)'
        '';
        ldapm_script = pkgs.writeShellScriptBin "ldapm" ''
          ${ldap_script}/bin/ldap "$@" | jq '[ .[].memberOf] | add'
        '';
        ldapg_script = pkgs.writeShellScriptBin "ldapg" ''
          ${ldap_script}/bin/ldap "$@" | jq '[ .[].member] | add'
        '';
      in
      [
        ldap_script
        ldapm_script
        ldapg_script
      ];
  };
}
