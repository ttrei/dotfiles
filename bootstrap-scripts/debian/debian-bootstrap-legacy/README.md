# Instructions

Install Debian testing daily build from https://cdimage.debian.org/cdimage/daily-builds/daily/arch-latest/amd64/iso-cd/
https://cdimage.debian.org/cdimage/daily-builds/daily/arch-latest/amd64/iso-cd/debian-testing-amd64-netinst.iso

If there was no network connection during installation then network must be configured manually.
Determine your network interface name and create a configuration file:

    $ ls /sys/class/net
    enp5s0 lo

``` /etc/network/interfaces.d/auto-dhcp
auto enp5s0
allow-hotplug enp5s0
iface enp5s0 inet dhcp
```

    # service networking restart

Configure sudo

    # apt update
    # apt install sudo
    # adduser reinis sudo # need to log out and log in again to get the rights

Get SSH keys
TODO: need to generate separate key for the new machine

    $ mkdir ~/.ssh
    $ chmod 700 ~/.ssh
    $ cp id_rsa id_rsa.pub ~/.ssh
    $ chmod 600 ~/.ssh id_rsa
    $ chmod 644 ~/.ssh id_rsa.pub

Create minimal `/etc/apt/sources.list` (bootstrap.sh will replace it):

```
echo "deb http://deb.debian.org/debian testing main contrib non-free" | sudo tee /etc/apt/sources.list
```

Get and run the bootstrap script:

    $ sudo apt update
    $ sudo apt install git
    $ git clone ssh://reinis@taukulis.lv/home/reinis/gitrepos/dev.git
    $ cd dev/
    $ git submodule update --init utilscripts
    $ cd utilscripts/debian-bootstrap
    $ git checkout master
    $ git pull
    $ ./bootstrap.sh
    $ sudo reboot

Export Passwords key on `reinis-pi`:

    $ gpg -a --export-secret-keys Passwords > privkey.asc

Import:

    $ scp -P 1046 reinis@reinis-pi:privkey.asc ./
    $ gpg --import privkey.asc

Don't forget to shred and remove `privkey.asc` on both machines.

# Wireless networking

https://wiki.debian.org/WiFi/HowToUse#WPA-PSK_and_WPA2-PSK

Generate the PSK key. The command will wait for you to enter the passphrase and
press Enter.

    wpa_passphrase <my_ssid> > /etc/wpa_supplicant/wpa_supplicant.conf

Append following lines to `/etc/wpa_supplicant/wpa_supplicant.conf`:
    ```
    ctrl_interface=/run/wpa_supplicant
    update_config=1
    ```

    systemctl reenable wpa_supplicant.service
    ip a # find out the wireless interface name (e.g., wlp5s0)
    touch /etc/network/interfaces.d/wlp5s0
    chmod 0600 /etc/network/interfaces.d/wlp5s0

Fill `/etc/network/interfaces.d/wlp5s0`:
    ```
    allow-hotplug wlp5s0
    iface wlp5s0 inet dhcp
        wpa-ssid <ssid>
        wpa-psk <copy the hexadecimal key from /etc/wpa_supplicant/wpa_supplicant.conf>
    ```

Try to bring up the interface. If unsuccessful, try restarting the system.

    ifup wlp5s0
