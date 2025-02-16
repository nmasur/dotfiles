# The Flame
# System configuration for an Oracle free server

# How to install:
# https://blog.korfuri.fr/posts/2022/08/nixos-on-an-oracle-free-tier-ampere-machine/
# These days, probably use nixos-anywhere instead.

rec {
  networking.hostName = "flame";

  nmasur.settings = {
    username = "noah";
    fullName = "Noah Masur";
    hostnames =
      let
        baseName = "masu.rs";
      in
      {
        budget = "money.${baseName}";
        git = "git.${baseName}";
        influxdb = "influxdb.${baseName}";
        irc = "irc.${baseName}";
        metrics = "metrics.${baseName}";
        minecraft = "minecraft.${baseName}";
        n8n = "n8n.${baseName}";
        notifications = "ntfy.${baseName}";
        prometheus = "prom.${baseName}";
        secrets = "vault.${baseName}";
        status = "status.${baseName}";
      };
  };

  nmasur.profiles = {
    base.enable = true;
    server.enable = true;
    communications.enable = true;
  };

  home-manager.users."noah" = {
    nmasur.settings = {
      username = nmasur.settings.username;
      fullName = nmasur.settings.fullName;
    };
    nmasur.profiles = {
      common.enable = true;
      linux-base.enable = true;
    };
  };

  # File systems must be declared in order to boot

  # This is the root filesystem containing NixOS
  # I forgot to set a clean label for it
  fileSystems."/" = {
    device = "/dev/disk/by-uuid/e1b6bd50-306d-429a-9f45-78f57bc597c3";
    fsType = "ext4";
  };

  # This is the boot filesystem for systemd-boot
  fileSystems."/boot" = {
    device = "/dev/disk/by-uuid/D5CA-237A";
    fsType = "vfat";
  };

  # Allows private remote access over the internet
  nmasur.presets.services.cloudflared = {
    tunnel = {
      id = "bd250ee1-ed2e-42d2-b627-039f1eb5a4d2";
      credentialsFile = ../../private/cloudflared-flame.age;
      ca = "ecdsa-sha2-nistp256 AAAAE2VjZHNhLXNoYTItbmlzdHAyNTYAAAAIbmlzdHAyNTYAAABBBK/6oyVqjFGX3Uvrc3VS8J9sphxzAnRzKC85xgkHfYgR3TK6qBGXzHrknEj21xeZrr3G2y1UsGzphWJd9ZfIcdA= open-ssh-ca@cloudflareaccess.org";
    };
  };
}
