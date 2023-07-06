sh mkrootfs.sh
qemu-system-aarch64 -s -S \
    -machine virt -cpu cortex-a57 \
    -kernel ~/kernel-openEuler-22.03-LTS/arch/arm64/boot/Image \
    -initrd initramfs.cpio.gz \
    -nographic \
    -append "nokaslr console=ttyAMA0"