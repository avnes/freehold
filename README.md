# freehold

Configure a CentOS Stream server for virtualization with libvirt on my home server called 'freehold'.
It will also setup automatic security patching.

## Requirements

- A user with sudo access

## Run instructions

```bash
make install
```

## Resize logical volumes

I needed to resize my /home and / paritions too, because I forgot to do it during installation.
With XFS, shrink is not possible, so I had to delete /home first before creating it again:

```bash
umount /home
lvremove /dev/mapper/cs-home
lvcreate -n home -L 50G cs
mkfs.xfs /dev/cs/home
mount /dev/mapper/cs-home
```

I also need to recreate my home directory:

```bash
mkdir -p /home/audun
chown audun:audun /home/audun
```## Known issues

If you forgot to partition your file system properly during installation, it is possible to do it later using these commands:

Extend root partition:

```bash
# Find free space:
vgs cs
lvextend -L +230G /dev/cs/root -r
```

Create a data partition:

```bash
# Find free space:
vgs cs
lvcreate -n data -L 100G cs
mkfs.xfs /dev/cs/data
mkdir /data
mount /dev/mapper/cs-data /data
```

Add new data partition to automount:

```bash
echo "/dev/mapper/cs-data     /data                   xfs     defaults        0 0" >> /etc/fstab
```
