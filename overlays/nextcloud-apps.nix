inputs: _final: prev: {

  nextcloudApps = {
    news = prev.fetchNextcloudApp {
      url = inputs.nextcloud-news.outPath;
      sha256 = inputs.nextcloud-news.sha256;
    };
    external = prev.fetchNextcloudApp {
      url = inputs.nextcloud-external.outPath;
      sha256 = inputs.nextcloud-external.sha256;
    };
    cookbook = prev.fetchNextcloudApp {
      url = inputs.nextcloud-cookbook.outPath;
      sha256 = inputs.nextcloud-cookbook.sha256;
    };
  };

}
