# ZFS

Swan runs its root on ext4. The ZFS drives are managed imperatively (this
[disko configuration](../disks/zfs.nix) is an unused work-in-progress).

The basic ZFS settings are managed [here](../modules/nixos/hardware/zfs.nix).

## Creating a New Dataset

```
sudo zfs create tank/mydataset
sudo zfs set compression=zstd tank/myzstddataset
sudo zfs set mountpoint=/data/mydataset tank/mydataset
```

