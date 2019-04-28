# Kubernetes under the hood
![](under-the-hood.jpg)

It even includes a SlideShare explaining the reasoning behid it [Kubernetes under the hood journey](https://pt.slideshare.net/MarcosVallim1/kubernetes-under-the-hood-journey/MarcosVallim1/kubernetes-under-the-hood-journey)

## Target Audience
The target audience for this tutorial is someone planning to install a Kubernetes cluster and wants to understand how everything fits together.

## Getting Started

### Creating Linux base image

#### Partitioning

The big decision about configuring Linux is how hard drive space is divided.

This design allows for dynamic growth and fine-tuning when needed. Being caught off guard with a scenario there is no more storage space available, with no immediate option other than deleting files is never a good experience. The long-term life and growth of the system, as well as the budgetary concerns, must be taken into account.

Isolating root volume, especially for static data that does not grow much over time, is the central concern. Isolating the other directories in their own volumes will be the strategy used so that their dynamic growth does not affect the root partition. Filling the root volume in a system is a very bad thing and should be avoided at all costs. With segregated partitions, we have margin of maneuver, like increasing one partition, reducing another, since the volume is not 100% occupied by the logical volumes (partitions).

Partitions may be increased later, but start with this minimum size, these numbers will be used for the initial installation of the system.

The volumes shall be initially divided as follows:

| Partition   | Size   | Description                                                                                            |
|-------------|--------|--------------------------------------------------------------------------------------------------------|
| **boot**    | 512 Mb | Boot loader files (ex: kernel, initrd). Single space residing outside the Logical Volume Manager (LVM) |
| **root**    | 2 Gb   | Operational System (/bin, /lib, /etc, /sbin)                                                           |
| **home**    | 2 Gb   | User directories.                                                                                      |
| **opt**     | 1 Gb   | Static application packages.                                                                           |
| **tmp**     | 1 Gb   | Temporary files.                                                                                       |
| **usr**     | 10 Gb  | Secondary hierarchy for shared user data whose access is restricted for read only.                     |
| **var**     | 10 Gb  | "Variable" files, such as logs, databases, web pages and e-mail files, container images, etc.          |
> **source:** http://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html)

#### Software
The installation of software packages that make up the base image are necessary to avoid repetition of work in the other VMs that will be created from it.

As we are creating an image using VirtualBox as our virtualization system an important software that should compose every image is VirtualBox Guest Additions, in addition to its dependencies.

The softwares to be installed will be the following:

| Software                       | Description                                                                                                     |
|--------------------------------|-----------------------------------------------------------------------------------------------------------------|
| **build-essential**            | This package contains an informational list of packages which are considered essential for building Debian packages.  This package also depends on the packages on that list, to make it easy to have the build-essential packages installed. |
| **module-assistant**           | The module-assistant tool (also known as m-a) helps users and maintainers with managing external Linux kernel modules packaged for Debian. It also contains some infrastructure to be used by the build-scripts in the accompanying modules-source packages in Debian. |
| **resolvconf**                 | Resolvconf is a framework for keeping up to date the system's information about name servers. It sets itself up as the intermediary between programs that supply this information (such as ifup and ifdown, DHCP clients, the PPP daemon and local name servers) and programs that use this information (such as DNS caches and resolver libraries). |
| **ntp**                        | NTP, the Network Time Protocol, is used to keep computer clocks accurate by synchronizing them over the Internet or a local network, or by following an accurate hardware receiver that interprets GPS, DCF-77, NIST or similar time signals. |
| **sudo**                       | Sudo is a program designed to allow a sysadmin to give limited root privileges to users and log root activity.  The basic philosophy is to give as few privileges as possible but still allow people to get their work done. |
| **cloud-init**                 | Cloud-init provides a framework and tool to configure and customize virtual machine instances for Infrastructure-as-a-Service (IaaS) clouds platforms. It can for example set a default locale and hostname, generate SSH private host keys, install SSH public keys for logging into a default account, set up ephemeral mount points, and run user-provided scripts. |
| **VirtualBox Guest Additions** | The VirtualBox Guest Additions consist of device drivers and system applications that optimize the operating system for better performance and usability. One of the usability features required in this guide is automated logons, which is why you need to install the Guest Additions in the virtual machine. |
> **source:** apt-cache show package-name

#### Installation
In the following videos you will be shown how to do a base installation for both Debian 9 Stretch and Ubuntu 18.04 LTS Server.

> **ISO install:** https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-9.9.0-amd64-DVD-1.iso
[![Debian 9 Stretch base image VirtualBox](http://i3.ytimg.com/vi/mG8scaDoZog/hqdefault.jpg)](https://youtu.be/mG8scaDoZog)

> **ISO install:** http://cdimage.ubuntu.com/ubuntu/releases/18.04/release/ubuntu-18.04.2-server-amd64.iso
[![Debian 9 Stretch base image VirtualBox](http://i3.ytimg.com/vi/Zo82rXBEzco/hqdefault.jpg)](https://youtu.be/Zo82rXBEzco)

#### Or if you prefere download base image

##### Debian
```
$ cd ~/VirtualBox\ VMs/

$ wget https://www.dropbox.com/s/xcsk4matlzmjo2m/debian-base-image.tar.bz2?dl=0 -O - | tar xvjf -

$ vboxmanage registervm ~/VirtualBox\ VMs/debian-base-image/debian-base-image.vbox
```

##### Ubuntu
```
$ cd ~/VirtualBox\ VMs/

$ wget https://www.dropbox.com/s/hicmmy39gc3gog2/ubuntu-base-image.tar.bz2?dl=0 -O - | tar xvjf -

$ vboxmanage registervm ~/VirtualBox\ VMs/ubuntu-base-image/ubuntu-base-image.vbox
```

## Configuring

### Prerequisites (GNU/Linux Debian/Ubuntu)

The premise is that you already have Virtualbox properly installed on your local machine.

Install `shyaml` with user `root`

```
# apt-get install python3-pip

# pip3 install shyaml
```

Install `genisoimage` with user `root`

```
# apt-get install genisoimage
```

### Configure Host Adapter VirtualBox
Create a Host-Only adpter on Virtualbox

```
$ vboxmanage hostonlyif create

$ vboxmanage hostonlyif ipconfig vboxnet0 --ip 192.168.254.1 --netmask 255.255.0.0
```

You need to add the routes on your local machine to access the internal network of Virtualbox.

```
$ sudo ip route add 192.168.1.0/24 via 192.168.1.254

$ sudo ip route add 192.168.2.0/24 via 192.168.2.254

$ sudo ip route add 192.168.3.0/24 via 192.168.3.254

$ sudo ip route add 192.168.4.0/24 via 192.168.4.254

$ sudo ip route add 192.168.254.0/24 via 192.168.254.254
```

## Running

Now let's create the images using a tool (create-image.sh) that will help us clone the base image and add the user-data, meta-data and network-config scripts that cloud-init will use to make the installation of the necessary packages and configurations.

```
$ ./create-image.sh \
    -k or --ssh-pub-keyfile SSH_PUB_KEY_FILE \
    -u or --user-data USER_DATA_FILE \
    -m or --meta-data META_DATA_FILE \
    -n or --network-interfaces NETWORK_INTERFACES_FILE \
    -i or --post-config-interfaces POST_CONFIG_INTERFACES_FILE \
    -s or --post-config-storages POST_CONFIG_STORAGES_FILE \
    -r or --post-config-resources POST_CONFIG_RESOURCES_FILE \
    -o or --hostname HOSTNAME \
    -b or --base-image BASE_IMAGE \
    -l or --linux-distribution LINUX_DISTRIBUTION \
    -a or --auto-start AUTO_START
```

### Parameters:
* __`SSH_PUB_KEY_FILE`__: Path to an SSH public key.
* __`USER_DATA_FILE`__: Path to an user data file. Default is '/data/user-data'.
* __`META_DATA_FILE`__: Path to an meta data file. Default is '/data/meta-data'.
* __`NETWORK_INTERFACES_FILE`__: Path to an network interface data file.
* __`POST_CONFIG_INTERFACES_FILE`__: Path to an post config interface data file.
* __`POST_CONFIG_STORAGES_FILE`__: Path to an post config storage data file.
* __`POST_CONFIG_RESOURCES_FILE`__: Path to an post config resources data file.
* __`HOSTNAME`__: Hostname of new image.
* __`BASE_IMAGE`__: Name of VirtualBox base image.
* __`LINUX_DISTRIBUTION`__: Name of Linux distribution. Default is 'debian'.
* __`AUTO_START`__: Auto start vm. Default is true.

For more information:
```
$ ./create-image.sh -h or --help
```

## Running Demo

All VM initializations and configurations use **cloud-init**, all YAML scripts are in the [data](/data) directory for the linux distribution used by VMs.

### Create gateway
```
$ ./create-image.sh \
    -k ~/.ssh/id_rsa.pub \
    -u gate/user-data \
    -n gate/network-config \
    -i gate/post-config-interfaces \
    -r gate/post-config-resources \
    -o gate-node01 \
    -l debian \
    -b debian-base-image
```

> Wait the gate-node01 finish the configuration and start VM, to the next steps.

### Create HAProxy Cluster

```
$ for instance in hapx-node01 hapx-node02; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u hapx/user-data \
        -i hapx/post-config-interfaces \
        -r hapx/post-config-resources \
        -o ${instance} \
        -l debian \
        -b debian-base-image
done
```

### Create Kubernete Masters
```
$ for instance in kube-mast01 kube-mast02 kube-mast03; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u kube/user-data \
        -i kube-mast/post-config-interfaces \
        -r kube-mast/post-config-resources \
        -o ${instance} \
        -l debian \
        -b debian-base-image
done
```

### Create Kube Workers
```
$ for instance in kube-node01 kube-node02 kube-node03; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u kube/user-data \
        -i kube-node/post-config-interfaces \
        -r kube-node/post-config-resources \
        -o ${instance} \
        -l debian \
        -b debian-base-image
done
```

### Create Gluster Nodes
```
$ for instance in glus-node01 glus-node02 glus-node03; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u glus/user-data \
        -i glus/post-config-interfaces \
        -s glus/post-config-storages \
        -r glus/post-config-resources \
        -o ${instance} \
        -l debian \
        -b debian-base-image
done
```

### Configure local hosts

You can configure in your local machine `/etc/hosts` with the ip and name of VM's.

For you get ip of VM:

```
vboxmanage guestproperty enumerate hapx-node01 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate hapx-node02 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'

vboxmanage guestproperty enumerate kube-mast01 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate kube-mast02 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate kube-mast03 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'

vboxmanage guestproperty enumerate kube-node01 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate kube-node02 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate kube-node03 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'

vboxmanage guestproperty enumerate glus-node01 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate glus-node02 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate glus-node03 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
```

Ex.

```
192.168.254.254 gate-node01 gate-node01.kube.local

192.168.1.10 kube-mast01 kube-mast01.kube.local
192.168.1.11 kube-mast02 kube-mast02.kube.local
192.168.1.10 kube-mast03 kube-mast03.kube.local

192.168.2.10 kube-node01 kube-node01.kube.local
192.168.2.11 kube-node02 kube-node02.kube.local
192.168.2.10 kube-node03 kube-node03.kube.local

192.168.3.10 glus-node01 glus-node01.kube.local
192.168.3.11 glus-node02 glus-node02.kube.local
192.168.3.10 glus-node03 glus-node03.kube.local

192.168.4.10 hapx-node01 hapx-node01.kube.local
192.168.4.11 hapx-node02 hapx-node02.kube.local
```

If you are a using dnsmasq on your local machine execute this to use private DNS of this DEMO to domain 'kube.local'

```
$ echo "server=/kube.local/192.168.254.254" | sudo tee -a /etc/dnsmasq.d/server

$ sudo service dnsmasq restart
```

### Configure HAProxy Cluster
```
ssh debian@hapx-node01.kube.local

sudo crm configure

property stonith-enabled=no
property no-quorum-policy=ignore
property default-resource-stickiness=100
primitive virtual-ip-resource ocf:heartbeat:IPaddr2 params ip="192.168.4.20" nic="enp0s3" cidr_netmask="32" meta migration-threshold=2 op monitor interval=20 timeout=60 on-fail=restart
primitive haproxy-resource ocf:heartbeat:haproxy op monitor interval=20 timeout=60 on-fail=restart
colocation loc inf: virtual-ip-resource haproxy-resource
order ord inf: virtual-ip-resource haproxy-resource
commit
bye
```

### Configure Kube Master
```
ssh debian@kube-mast01.kube.local

sudo su -

cat <<EOF > kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable-1.13
apiServer:
  certSANs:
  - "192.168.4.20"
controlPlaneEndpoint: "192.168.4.20:6443"
networking:
  podSubnet: 10.244.0.0/16
EOF

kubeadm init --config=kubeadm-config.yaml

mkdir -p $HOME/.kube

cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml

ssh-keygen -t rsa -b 4096

ssh-copy-id debian@kube-mast02 #(default password: debian)

ssh-copy-id debian@kube-mast03 #(default password: debian)

~/bin/copy-certificates.sh

kubeadm token create --print-join-command
```
> The last command print the command to you join nodes on cluster, you will use this command to join master and wokers on cluster

#### Join second Kube Master
```
ssh debian@kube-mast02.kube.local

sudo su -

~/bin/move-certificates.sh

kubeadm join 192.168.4.20:6443 \
    --token ??? \
    --discovery-token-ca-cert-hash sha256:??? \
    --experimental-control-plane
```

#### Join third Kube Master
```
ssh debian@kube-mast03.kube.local

sudo su -

~/bin/move-certificates.sh

kubeadm join 192.168.4.20:6443 \
    --token ??? \
    --discovery-token-ca-cert-hash sha256:??? \
    --experimental-control-plane
```

### Join Kube Workers

#### Join first Kube Worker
```
ssh debian@kube-node01.kube.local

sudo su -

kubeadm join 192.168.4.20:6443 \
    --token ??? \
    --discovery-token-ca-cert-hash sha256:??? \
```

#### Join second Kube Worker
```
ssh debian@kube-node02.kube.local

sudo su -

kubeadm join 192.168.4.20:6443 \
    --token ??? \
    --discovery-token-ca-cert-hash sha256:??? \
```

#### Join third Kube Worker
```
ssh debian@kube-node03.kube.local

sudo su -

kubeadm join 192.168.4.20:6443 \
    --token ??? \
    --discovery-token-ca-cert-hash sha256:??? \
```

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [GitHub](https://github.com/mvallim/kubernetes-under-the-hood) for versioning. For the versions available, see the [tags on this repository](https://github.com/mvallim/kubernetes-under-the-hood/tags). 

## Authors

* **Marcos Vallim** - *Initial work, Development, Test, Documentation* - [mvallim](https://github.com/mvallim)
* **Fabio Franco Uechi** - *Validation demo* - [fabito](https://github.com/fabito)
* **Dirceu Alves Silva** - *Validation demo* - [dirceusilva](https://github.com/dirceuSilva)
* **Leandro Nunes Fantinatto** - *Validation demo* - [lnfnunes](https://github.com/lnfnunes)
* **Ivam dos Santos Luz** - *Validation demo, Articles* - [ivamluz](https://github.com/ivamluz)
* **Marcos de Lima Goncalves** - *Validation demo, Presentation Organizer* - [marcoslimagon](https://github.com/marcoslimagon)
* **Murilo Woigt Miranda** - *Validation demo, Presentation Organizer* - [woigt-ciandt](https://github.com/woigt-ciandt)

See also the list of [contributors](CONTRIBUTORS.txt) who participated in this project.

## License

This project is licensed under the BSD License - see the [LICENSE](LICENSE) file for details
