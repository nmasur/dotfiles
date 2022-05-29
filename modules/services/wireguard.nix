{ ... }: {
  networking.wireguard.interfaces = {
    wg0 = {
      ips = [ "10.0.0.1/32" "fc00:bbbb:bbbb:bb01::3:7fea/128" ];
      privateKeyFile = "/private/wireguard-pk";
      peers = [{
        publicKey = "ABCDEFABCDEF";
        allowedIPs = [ "0.0.0.0/0" "::0/0" ];
        endpoint = "10.0.0.1:51820";
        persistentKeepalive = 25;
      }];
    };
  };
}
