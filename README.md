# linux-rootfs-arm64

In order to enable qemu's net service, you need to create follow files:

```shell
➜  ~ mkdir /etc/qemu
➜  ~ echo 'allow all' > /etc/qemu/bridge.conf
➜  ~ mkdir -p /dev/net
➜  ~ mknod /dev/net/tun c 10 200
➜  ~ chmod 600 /dev/net/tun
```

This branch is A simple root file system built by busybox for linux-arm64.

You may see some folders with only `.gitkeep` files, this is to prevent git from ignoring these empty directories. These empty directories are all necessary in the root filesystem.

There is a `MAKEDEV` file in `initramfs/dev/`, you need to go into this directory and run MAKEDEV before all:

```shell
➜  linux-rootfs cd initramfs/dev 
➜  dev sh MAKEDEV
```

Then please ensure that the execute permission for the files has been enabled:

```shell
➜  linux-rootfs sudo chmod a+x initramfs/init
➜  linux-rootfs sudo chmod a+x initramfs/etc/init.d/rcS
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
➜  _install mkdir etc dev lib proc sys tmp mnt
➜  _install touch init
➜  _install chmod a+x init
➜  _install rm linuxrc
```

Write the following in the `init` file:

```shell
➜  _install cat init
#!/bin/busybox sh
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
mdev -s

```

Create device files in the `dev/` directory:

```shell
➜  _install cd dev/
➜  dev mknod console c 5 1
```

Then, create the `initramfs`:

```shell
➜  linux-rootfs mkdir initramfs
➜  linux-rootfs cd initramfs
➜  initramfs cp ~/busybox-1.36.0/_install/* -rf ./
```

Finally, package the `initramfs`:

```bash
➜  linux-rootfs cd initramfs
➜  initramfs find . -print0 | cpio --null -ov --format=newc | gzip -9 > ../initramfs.cpio.gz
```

**权限问题**

如果并不是以root身份构造busybox，则有可能会出现：mount: you must be root 报错。因此需要将 bin 目录下所有文件修改拥有者为root：

```bash
➜  bin sudo chown root * -R
```

# bullsyes根文件系统

create-image.sh来源：https://github.com/google/syzkaller/blob/master/tools/create-image.sh

这是一个用于创建最小化Debian Linux镜像的脚本，主要用于syzkaller（一个内核模糊测试工具）项目。我没去掉里面syzkaller相关的部分。

但是做了如下小修改：

```
# 可能会需要某种修改！把enp0s1改成ip link show查询出的设备名
printf '\nauto enp0s1\niface enp0s1 inet dhcp\n' | sudo tee -a $DIR/etc/network/interfaces
```

如果你搜索启动日志，会看到这样一条：`virtio_net virtio1 enp0s1: renamed from eth0`。这是因为使用systemd的发行版Linux采用了"可预测网络接口命名"机制。它不再使用传统的 eth0、eth1 这样的名称，而是根据设备的物理/虚拟特性来命名。因此/etc/network/interfaces中的eth0要改成enp0s1。

但是我最近遇到了`ip link show`什么也查不出来的情况，可能是内核配置没有开相应的选项。那么如果启动不了就不是这里的问题了。


`/etc/fstab`修改：

```
# 把qemu虚拟机中的/mnt挂在到物理机上
mount-1 /mnt 9p trans=virtio,version=9p2000.L,posixacl,msize=512000 0 0
```

然后把qemu启动命令加上：

```
    -fsdev local,path=/root/mnt_path/,security_model=mapped,id=dev-1 \
    -device virtio-9p-device,fsdev=dev-1,mount_tag=mount-1 \
```
