# Kubernetes under the hood
![](under-the-hood.jpg)

SlideShare: [Kubernetes under the hood journey](https://pt.slideshare.net/MarcosVallim1/kubernetes-under-the-hood-journey/MarcosVallim1/kubernetes-under-the-hood-journey)

## Target Audience
The target audience for this tutorial is someone planning to install a Kubernetes cluster and wants to understand how everything fits together.

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

### Create gateway
```
$ ./create-image.sh \
    -k ~/.ssh/id_rsa.pub \
    -u data/gate/user-data \
    -n data/gate/network-config \
    -i data/gate/post-config-interfaces \
    -r data/gate/post-config-resources \
    -o gate-node01 \
    -b image-base
```

Wait the gate-node01 finish the configuration and start VM, to the next steps.

### Create HAProxy Cluster
```
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
```

### Create Kubernete Masters
```
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
```

### Create Kube Workers
```
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
```

### Create Gluster Nodes
```
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

### Configure hosts

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
kubernetesVersion: stable
apiServer:
  certSANs:
  - "192.168.4.20"
controlPlaneEndpoint: "192.168.4.20:6443"
networking:
  podSubnet: 10.244.0.0/16
EOF

kubeadm init --config=kubeadm-config.yaml

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml

ssh-keygen -t rsa -b 4096

ssh-copy-id debian@kube-mast02

ssh-copy-id debian@kube-mast03

~/bin/copy-certificates.sh

kubeadm token create --print-join-command
```

The last command print the command to you join nodes on cluster, you will use this command to join master and wokers on cluster

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
