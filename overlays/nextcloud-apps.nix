inputs: _final: prev: {

  nextcloudApps = {
    news = prev.fetchNextcloudApp {
      url = inputs.nextcloud-news.outPath;
      sha256 = inputs.nextcloud-news.narHash;
    };
    external = prev.fetchNextcloudApp {
      url = inputs.nextcloud-external.outPath;
      sha256 = inputs.nextcloud-external.narHash;
    };
    cookbook = prev.fetchNextcloudApp {
      url = inputs.nextcloud-cookbook.outPath;
      sha256 = inputs.nextcloud-cookbook.narHash;
    };
  };

}
