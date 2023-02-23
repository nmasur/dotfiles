{ bootDisk, storageDisks ? [ "/dev/vdb" "/dev/vdc" ], ... }: {
  disk = {
    boot = {
      type = "disk";
      device = "/dev/whatever";
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          {
            type = "partition";
            name = "ESP";
            start = "0";
            end = "512MiB";
            fs-type = "fat32";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
            };
          }
          {
            type = "partition";
            name = "root";
            start = "512MiB";
            end = "100%";
            part-type = "primary";
            bootable = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
            };
          }
        ];
      };
    };
    a = {
      type = "disk";
      device = builtins.elemAt storageDisks 1;
      content = {
        type = "table";
        format = "gpt";
        partitions = [{
          type = "partition";
          name = "zfs";
          start = "128MiB";
          end = "100%";
          content = {
            type = "zfs";
            pool = "tank";
          };
        }];
      };
    };
  };
  zpool = {
    tank = {
      type = "zpool";
      mode = "raidz1";
      rootFsOptions = {
        compression = "on"; # lz4 by default
        "com.sun:auto-snapshot" = "false";
        ashift = 12;
      };
      # mountpoint = "/";

      datasets = {
        media = {
          zfs_type = "filesystem";
          mountpoint = "none";
          options."com.sun:auto-snapshot" = "false";
        };
        # "media/movies" = {
        #   zfs_type = "filesystem";
        #   mountpoint = "/media/movies";
        #   options.recordsize = "1M";
        # };
        # "media/tv" = {
        #   zfs_type = "filesystem";
        #   mountpoint = "/media/tv";
        #   options.recordsize = "1M";
        # };
        # "media/books" = {
        #   zfs_type = "filesystem";
        #   mountpoint = "/media/books";
        # };
        # archive = {
        #   zfs_type = "filesystem";
        #   mountpoint = "/archive";
        #   options.compression = "zstd";
        #   options."com.sun:auto-snapshot" = "true";
        # };
        # zfs_unmounted_fs = {
        #   zfs_type = "filesystem";
        #   options.mountpoint = "none";
        # };
        # zfs_legacy_fs = {
        #   zfs_type = "filesystem";
        #   options.mountpoint = "legacy";
        #   mountpoint = "/zfs_legacy_fs";
        # };
        # zfs_testvolume = {
        #   zfs_type = "volume";
        #   size = "10M";
        #   content = {
        #     type = "filesystem";
        #     format = "ext4";
        #     mountpoint = "/ext4onzfs";
        #   };
        # };
        encrypted = {
          zfs_type = "filesystem";
          size = "20M";
          options = {
            mountpoint = "none";
            encryption = "aes-256-gcm";
            keyformat = "passphrase";
            keylocation = "file:///tmp/secret.key";
          };
        };
        "encrypted/test" = {
          zfs_type = "filesystem";
          size = "2M";
          mountpoint = "/zfs_crypted";
        };
      };
    };
  };
}
