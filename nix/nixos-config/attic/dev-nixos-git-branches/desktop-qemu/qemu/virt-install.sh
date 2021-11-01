# STATUS: Didn't manage to automate this. Communication with VM guest tty doens't work.
# For now we create VMs manually through virt-manager.

# Consulted these resources. Maybe the answer is there.
# https://unix.stackexchange.com/questions/309788/how-to-create-a-vm-from-scratch-with-virsh
# https://www.thegeekstuff.com/2014/10/linux-kvm-create-guest-vm/
# https://github.com/rancher/k3os/issues/133

virt-install \
--connect qemu:///system \
--name nixos3 \
--description "Nixos 3" \
--os-type=Linux \
--os-variant=none \
--memory=4096 \
--vcpus=4 \
--disk pool=storage,path=/media/Storage/qemu/nixos2.qcow2,format=qcow2,bus=virtio,size=40 \
--graphics none \
--cdrom /media/Storage/install/nixos-minimal-19.09.2036.c49da6435f3-x86_64-linux.iso \
--install kernel=/tmp/boot-nixos/bzImage,initrd=/tmp/boot-nixos/initrd \
--location /media/Storage/install/nixos-minimal-19.09.2036.c49da6435f3-x86_64-linux.iso \
--network bridge:virbr0 \
--console pty,target_type=serial \
--extra-args console=ttyS0

#--location /media/Storage/install/nixos-minimal-19.09.2036.c49da6435f3-x86_64-linux.iso,kernel=boot/bzImage,initrd=boot/initrd \
