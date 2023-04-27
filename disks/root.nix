{ disk, ... }: {
  disk = {
    boot = {
      type = "disk";
      device = disk;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          # Boot partition
          {
            name = "ESP";
            start = "0";
            end = "512MiB";
            fs-type = "fat32";
            bootable = true;
            content = {
              type = "filesystem";
              format = "vfat";
              mountpoint = "/boot";
              extraArgs = [ "-n boot" ];
            };
          }
          # Root partition ext4
          {
            name = "root";
            start = "512MiB";
            end = "100%";
            part-type = "primary";
            bootable = true;
            content = {
              type = "filesystem";
              format = "ext4";
              mountpoint = "/";
              extraArgs = [ "-L nixos" ];
            };
          }
        ];
      };
    };
  };
}
