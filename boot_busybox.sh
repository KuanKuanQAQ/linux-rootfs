# sh mkrootfs.sh
sudo qemu-system-aarch64 -s \
    -machine virt -cpu cortex-a57 \
    -m 8192 \
    -kernel ~/Image \
    -initrd initramfs.cpio.gz \
    -fsdev local,path=/root/mnt_path/,security_model=mapped,id=dev-1 \
    -device virtio-9p-device,fsdev=dev-1,mount_tag=mount-1 \
    -netdev bridge,id=en0,br=virbr0 -device virtio-net-pci,netdev=en0 \
    -nographic \
    -append "nokaslr console=ttyAMA0"
