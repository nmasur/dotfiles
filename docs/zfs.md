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

## Maintenance

### Get Status

```
sudo zpool status
```

### Replace Disk

```
sudo zdb
sudo zpool status -g # Show by GUID
sudo zpool offline tank <GUID>
sudo zpool status
# Remove old disk, insert new disk
sudo zdb
sudo zpool replace tank <OLD GUID> /dev/disk/by-id/<NEW PATH>
sudo zpool status
```

## Initial Setup

```
sudo zpool create tank raidz1 sda sdb sdc
sudo zpool set ashift=12 tank
sudo zpool set autoexpand=on tank
sudo zpool set compression=on tank
```

