{ disk, ... }: {
  disk = {
    boot = {
      type = "disk";
      device = disk;
      content = {
        type = "gpt";
        partitions = {
          # Boot partition
          ESP = {
            size = "512MiB";
            type = "EF00";
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [ "-n boot" ];
            };
          };
          # Root partition ext4
          root = {
            size = "100%";
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              extraArgs = [ "-L nixos" ];
            };
          };
        };
      };
    };
  };
}
