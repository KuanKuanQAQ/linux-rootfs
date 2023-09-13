# linux-rootfs-arm64

This branch is A simple root file system built by busybox for linux-arm64.

You may see some folders with only `.gitkeep` files, this is to prevent git from ignoring these empty directories. These empty directories are all necessary in the root filesystem.

There is a `MAKEDEV` file in `initramfs/dev/`, you need to go into this directory and run MAKEDEV before all:
```shell
cd initramfs/dev/
sh MAKEDEV
```
## shared file
https://github.com/dk-penguins/docs/blob/main/环境配置方案/QEMU共享目录.md