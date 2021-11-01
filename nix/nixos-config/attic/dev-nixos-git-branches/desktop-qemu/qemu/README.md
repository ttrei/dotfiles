# Create new virtual machine in virt-manager

Create the machine under QEMU/KVM Connection (corresponds to -c qemu:///system)
to avoid problems with networking.
Use Generic operating system.
Create new virtual disk.

# installation

```
sudo su
passwd
systemctl start sshd.service
ip addr # Add this ip address to /etc/hosts on VM host
# now you can SSH into the machine

nix-env -iA nixos.git
git clone ssh://reinis@178.62.54.226:/home/reinis/gitrepos/nixos.git
cd nixos
git checkout desktop-qemu
./qemu/01-nixos-install.sh
```

# after installation

```
# as root
ssh-keygen
ssh-copy-id reinis@mazais

# as regular user
ssh-keygen
ssh-copy-id reinis@mazais
/etc/nixos/qemu/02-configure-home.sh
```
