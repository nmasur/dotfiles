inputs: _final: prev: {

  nextcloudApps = {
    news = prev.fetchNextcloudApp {
      url = inputs.nextcloud-news.outPath;
      sha256 = inputs.nextcloud-news.narHash;
      license = "agpl3Plus";
      unpack = true;
    };
    external = prev.fetchNextcloudApp {
      url = inputs.nextcloud-external.outPath;
      sha256 = inputs.nextcloud-external.narHash;
      license = "agpl3Plus";
      unpack = true;
    };
    cookbook = prev.fetchNextcloudApp {
      url = inputs.nextcloud-cookbook.outPath;
      sha256 = inputs.nextcloud-cookbook.narHash;
      license = "agpl3Plus";
      unpack = true;
    };
    snappymail = prev.fetchNextcloudApp {
      url = inputs.nextcloud-snappymail.outPath;
      sha256 = inputs.nextcloud-snappymail.narHash;
      license = "agpl3Plus";
      unpack = true;
    };
  };
}
