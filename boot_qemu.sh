# Remove previously created network interfaces.
sudo ip link set dev tap0 down 2> /dev/null
sudo ip link del dev tap0 2> /dev/null
sudo ip link set dev virbr0 down 2> /dev/null
sudo ip link del dev virbr0 2> /dev/null

# Create bridge interface for QEMU networking.
sudo ip link add dev virbr0 type bridge
sudo ip address add 172.17.0.1/24 dev virbr0
sudo ip link set dev virbr0 up

# sh mkrootfs.sh
qemu-system-aarch64 -s \
    -machine virt -cpu cortex-a57 \
    -m 8192 \
    -kernel ~/Image \
    -initrd initramfs.cpio.gz \
    -fsdev local,path=/root/mnt_path/,security_model=mapped,id=dev-1 \
    -device virtio-9p-device,fsdev=dev-1,mount_tag=mount-1 \
    -netdev bridge,id=en0,br=virbr0 -device virtio-net-pci,netdev=en0 \
    -nographic \
    -append "nokaslr console=ttyAMA0"
