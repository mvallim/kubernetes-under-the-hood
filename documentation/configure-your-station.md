## Configuring your station

## Prerequisites (GNU/Linux Debian/Ubuntu)

The premise is that you already have Virtualbox properly installed on your local machine.

### Add your user on `vboxusers`
```
sudo usermod -a -G vboxusers $USER
```
---

### Install `shyaml`
```
sudo apt-get install python3-pip

sudo pip3 install shyaml
```
---

### Install `genisoimage`
```
sudo apt-get install genisoimage
```
---

### Install `uuid-runtime`
```
sudo apt-get install uuid-runtime
```
---

### Install `resolvconf`
```
sudo apt-get install resolvconf
```
---

### Install `dnsmasq-base`
```
sudo apt-get install dnsmasq-base
```
---

### Configure `dnsmasq` on NetworkManager
```
sudo systemctl disable systemd-resolved.service

sudo systemctl stop systemd-resolved.service

sudo rm -rf /etc/resolvconf/resolv.conf.d/original

sudo touch /etc/resolvconf/resolv.conf.d/original

sudo truncate -s 0 /etc/resolv.conf

sudo sed -i -r 's/^(hosts\:.*)\[NOTFOUND=return\] (.*)/\1\2/g' /etc/nsswitch.conf

sudo sed -i '/^\[main\]/a dns=dnsmasq' /etc/NetworkManager/NetworkManager.conf

sudo sed -i '/^\[main\]/a rc-manager=resolvconf' /etc/NetworkManager/NetworkManager.conf

echo "server=/kube.local/192.168.1.1" | sudo tee -a /etc/NetworkManager/dnsmasq.d/server

echo "server=/kube.local/192.168.2.1" | sudo tee -a /etc/NetworkManager/dnsmasq.d/server

echo "server=/kube.local/192.168.3.1" | sudo tee -a /etc/NetworkManager/dnsmasq.d/server

echo "server=/kube.local/192.168.4.1" | sudo tee -a /etc/NetworkManager/dnsmasq.d/server

echo "cache-size=10000" | sudo tee -a /etc/NetworkManager/dnsmasq.d/cache

sudo systemctl restart network-manager
```
---

### Configure Host Adapter VirtualBox
Create a Host-Only adpter on Virtualbox

```
vboxmanage hostonlyif create

vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.254.1 --netmask 255.255.0.0
```
