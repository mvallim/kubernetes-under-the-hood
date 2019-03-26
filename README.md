# Kubernetes under the hood
![](under-the-hood.jpg)

## Getting Started

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

### Download base image
To continue with this demo you need to download the base image and register it in Virtualbox.

```
$ cd ~/VirtualBox\ VMs/

$ wget https://www.dropbox.com/s/v6h0sedqt3za9pl/image-base.tar.bz2?dl=0 -O image-base.tar.bz2

$ tar xvjf image-base.tar.bz2

$ vboxmanage registervm ~/VirtualBox\ VMs/image-base/image-base.vbox

$ rm image-base.tar.bz2
```

## Configuring

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

If you are a using dnsmasq on your local machine execute this to use private DNS of this DEMO to domain 'kube.local'

```
$ echo "server=/kube.local/192.168.254.254" | sudo tee -a /etc/dnsmasq.d/server

$ sudo service dnsmasq restart
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
* __`AUTO_START`__: Auto start vm. Default is true.

For more information:
```
$ ./create-image.sh -h or --help
```

## Running Demo

```
$ ./create-image.sh \
    -k ~/.ssh/id_rsa.pub \
    -u data/gate/user-data \
    -n data/gate/network-config \
    -i data/gate/post-config-interfaces \
    -r data/gate/post-config-resources \
    -o gate-node01 \
    -b image-base

$ for instance in hapx-node01 hapx-node02; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u data/hapx/user-data \
        -n data/hapx/network-config \
        -i data/hapx/post-config-interfaces \
        -r data/hapx/post-config-resources \
        -o ${instance} \
        -b image-base
done

$ for instance in kube-mast01 kube-mast02 kube-mast03; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u data/kube/user-data \
        -n data/kube/network-config \
        -i data/kube-mast/post-config-interfaces \
        -r data/kube-mast/post-config-resources \
        -o ${instance} \
        -b image-base
done

$ for instance in kube-node01 kube-node02 kube-node03; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u data/kube/user-data \
        -n data/kube/network-config \
        -i data/kube-node/post-config-interfaces \
        -r data/kube-node/post-config-resources \
        -o ${instance} \
        -b image-base
done

$ for instance in glus-node01 glus-node02 glus-node03; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u data/glus/user-data \
        -n data/glus/network-config \
        -i data/glus/post-config-interfaces \
        -s data/glus/post-config-storages \
        -r data/glus/post-config-resources \
        -o ${instance} \
        -b image-base
done
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
