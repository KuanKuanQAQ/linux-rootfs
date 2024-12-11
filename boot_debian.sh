qemu-system-aarch64 -s \
    -machine virt -cpu cortex-a57 \
    -m 8192 \
    -kernel  ~/Image \
    -drive file=./bullseye.img,format=raw \
    -fsdev local,path=/root/mnt_path/,security_model=mapped,id=dev-1 \
    -device virtio-9p-device,fsdev=dev-1,mount_tag=mount-1 \
    -nographic \
    -append "nokaslr console=ttyAMA0 root=/dev/vda"
