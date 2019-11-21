# Configuring your station

## Prerequisites (GNU/Linux Debian/Ubuntu)

The premise is that you already have Virtualbox properly installed on your local machine.

### Add your user on `vboxusers`

```shell
sudo usermod -a -G vboxusers $USER
```

---

### Install `shyaml`

```shell
sudo apt-get install python3-pip

sudo pip3 install shyaml
```

---

### Install `genisoimage`

```shell
sudo apt-get install genisoimage
```

---

### Install `uuid-runtime`

```shell
sudo apt-get install uuid-runtime
```

---

### Configure Host Adapter VirtualBox

Create a Host-Only adpter on Virtualbox

```shell
# Gateway - vboxnet0
vboxmanage hostonlyif create

# Gateway - vboxnet0 configuration
vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.254.1 --netmask 255.255.0.0

# BusyBox - vboxnet1
vboxmanage hostonlyif create

# BusyBox - vboxnet1 configuration
vboxmanage hostonlyif ipconfig vboxnet1 --ip 192.168.253.1 --netmask 255.255.255.0
```
