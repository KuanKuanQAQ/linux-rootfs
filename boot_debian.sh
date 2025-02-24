sudo qemu-system-aarch64 -s \
    -machine virt -cpu cortex-a57 \
    -m 8192 \
    -kernel ~/Image \
    -drive file=./bullseye.img,format=raw \
    -fsdev local,path=/root/mnt_path/,security_model=mapped,id=dev-1 \
    -device virtio-9p-device,fsdev=dev-1,mount_tag=mount-1 \
    -nographic \
    -append "nokaslr console=ttyAMA0 root=/dev/vda"


sudo qemu-system-x86_64 -s \
    -enable-kvm -cpu host \
    -m 16G -smp 8 \
    -kernel ~/Image \
    -initrd ../bullseye.img \
    -fsdev local,path=/home/lrk/mnt_path/,security_model=mapped,id=dev-1 \
    -device virtio-9p,fsdev=dev-1,mount_tag=mount-1 \
    -nographic \
    -append "nokaslr console=ttyS0 root=/dev/ram0 earlyprintk=serial ramdisk_size=2097152" \
