## Configuring your station

### Prerequisites (GNU/Linux Debian/Ubuntu)

The premise is that you already have Virtualbox properly installed on your local machine.

Install `shyaml` with user `root`

```
apt-get install python3-pip

pip3 install shyaml
```

Install `genisoimage` with user `root`

```
apt-get install genisoimage
```

### Configure Host Adapter VirtualBox
Create a Host-Only adpter on Virtualbox

```
vboxmanage hostonlyif create

vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.254.1 --netmask 255.255.0.0
```

You need to add the routes on your local machine to access the internal network of Virtualbox.

```
sudo ip route add 192.168.1.0/24 via 192.168.1.254 dev vboxnet0

sudo ip route add 192.168.2.0/25 via 192.168.2.254 dev vboxnet0

sudo ip route add 192.168.2.128/25 via 192.168.2.254 dev vboxnet0

sudo ip route add 192.168.3.0/24 via 192.168.3.254 dev vboxnet0

sudo ip route add 192.168.4.0/25 via 192.168.4.254 dev vboxnet0

sudo ip route add 192.168.4.128/25 via 192.168.4.254 dev vboxnet0
```