{ disks, ... }: {
  disk = {
    boot = {
      type = "disk";
      device = builtins.elemAt disks 0;
      content = {
        type = "table";
        format = "gpt";
        partitions = [
          # Boot partition
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
              extraArgs = [ "-n boot" ];
            };
          }
          # Root partition ext4
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
              extraArgs = [ "-L nixos" ];
            };
          }
        ];
      };
    };
  };
}
