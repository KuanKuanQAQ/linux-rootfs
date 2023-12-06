# linux-rootfs-arm64

This branch is A simple root file system built by busybox for linux-arm64.

You may see some folders with only `.gitkeep` files, this is to prevent git from ignoring these empty directories. These empty directories are all necessary in the root filesystem.

There is a `MAKEDEV` file in `initramfs/dev/`, you need to go into this directory and run MAKEDEV before all:

```shell
sh initramfs/dev/MAKEDEV
```

Then please ensure that the execute permission for the file `initramfs/init` has been enabled:

```shell
sudo chmod a+x initramfs/init
```

This root file system includes a mount directory `mnt/`. This directory is mounted to the `/root/mnt_path/` directory on the physical machine. Files between them will be synchronized.

Below is my build process.

## Compiling BusyBox from Source

Download the BusyBox source code: https://busybox.net/downloads/busybox-1.36.0.tar.bz2

Before compiling BusyBox, change a setting:

```shell
➜  ~ cd busybox-1.36.0
➜  busybox-1.36.0 make menuconfig
```

Turn on the `setting -> [*] Build static binary (no shared libs)`.

```shell
➜  busybox-1.36.0 make -j 40
➜  busybox-1.36.0 make install
```

## Building the Root File System

```shell
➜  ~ cd busybox-1.36.0/_install
➜  _install mkdir etc dev lib proc sys
➜  _install touch init
➜  _install chmod a+x init
➜  _install rm linuxrc
```

Write the following in the `init` file:

```shell
➜  _install cat init
#!/bin/busybox sh
mount -t proc none /proc
mount -t sysfs none /sys

exec /sbin/init
```

Create the following files in the `etc/` directory:

```shell
➜  _install cd etc/
➜  etc cat profile 
#!/bin/sh
export HOSTNAME=kuankuanQAQ
export USER=root
export HOME=/home
export PS1="[$USER@$HOSTNAME \W]\# "
PATH=/bin:/sbin:/usr/bin:/usr/sbin
LD_LIBRARY_PATH=/lib:/usr/lib:$LD_LIBRARY_PATH
export PATH LD_LIBRARY_PATH

➜  etc cat inittab 
::sysinit:/etc/init.d/rcS
::respawn:-/bin/sh
::askfirst:-/bin/sh
::ctrlaltdel:/bin/umount -a -r

➜  etc cat fstab 
#device  mount-point    type     options   dump   fsck order
proc /proc proc defaults 0 0
tmpfs /tmp tmpfs defaults 0 0
sysfs /sys sysfs defaults 0 0
tmpfs /dev tmpfs defaults 0 0
debugfs /sys/kernel/debug debugfs defaults 0 0
mount-1 /mnt 9p trans=virtio,version=9p2000.L,posixacl,msize=104857600 0 0

➜  etc cat init.d/rcS 
touch /etc/passwd
touch /etc/group
echo root:x:0:0:root:/root:/bin/sh > /etc/passwd
echo root:x:0: > /etc/group
chmod 4755 /bin/busybox

/bin/mount -a
mount -t devpts devpts /dev/pts
mdev -s

```

Create device files in the `dev/` directory:

```shell
➜  _install cd dev/
➜  dev mknod console c 5 1
➜  dev mkdir pts
```

Then, create the `initramfs`:

```shell
➜  rootfs mkdir initramfs
➜  rootfs cd initramfs
➜  initramfs cp ~/busybox-1.36.0/_install/* -rf ./
```

Finally, package the `initramfs`:

```bash
➜  rootfs cd initramfs
➜  initramfs find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
```
