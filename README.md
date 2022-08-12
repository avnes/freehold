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
## Setup CoreDNS

```bash
useradd coredns -s /sbin/nologin -c 'coredns user'

curl -LO https://github.com/coredns/coredns/releases/download/v1.9.3/coredns_1.9.3_linux_amd64.tgz
tar zxvf coredns_1.9.3_linux_amd64.tgz
chmod +x coredns
sudo mv coredns /usr/bin
rm zxvf coredns_1.9.3_linux_amd64.tgz

cp coredns.service /usr/lib/systemd/system/coredns.service
chmod +x /usr/lib/systemd/system/coredns.service
mkdir -p /etc/coredns
cp Corefile /etc/coredns

systemctl enable coredns
systemctl start coredns

firewall-cmd --permanent --zone=public --add-port=53/tcp
firewall-cmd --permanent --zone=public --add-port=53/udp
firewall-cmd --reload

# On my VMs, I can now use this new DNS server:
# curl https://raw.githubusercontent.com/avnes/freehold/main/vm-dns-override.sh | bash
```
