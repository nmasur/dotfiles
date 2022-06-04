{ ... }: {
  networking.wireguard = {
    enable = true;
    interfaces = {
      wg0 = {
        ips = [ "10.66.127.235/32" "fc00:bbbb:bbbb:bb01::3:7fea/128" ];
        generatePrivateKeyFile = true;
        privateKeyFile = "/private/wireguard/wg0";
        peers = [{
          publicKey = "cVDIYPzNChIeANp+0jE12kWM5Ga1MbmNErT1Pmaf12A=";
          allowedIPs = [ "0.0.0.0/0" "::0/0" ];
          endpoint = "89.46.62.197:51820";
          persistentKeepalive = 25;
        }];
      };
    };
  };
}
