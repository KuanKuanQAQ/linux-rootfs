qemu-system-aarch64 -s \
    -machine virt -cpu cortex-a57 \
    -m 8192 \
    -kernel /root/Image \
    -drive file=/root/image/bullseye.img,format=raw \
    -net user,host=10.0.2.10,hostfwd=tcp:127.0.0.1:10021-:22 \
    -net nic,model=e1000 \
    -nographic \
    -append "nokaslr console=ttyAMA0 root=/dev/sda earlyprintk=serial net.ifnames=0"
