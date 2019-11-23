# Running

Now let's create the images using a tool ([`create-image.sh`](/create-image.sh)) that will help us clone the base image and add the user-data, meta-data and network-config scripts that cloud-init will use to install the necessary packages and configurations.

``` Shell
./create-image.sh \
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

## Parameters

* `-k` is used to copy the public key from your host inside the newly created VM.
* `-u` is used to specify the user-data file that will be passed as a parameter to the command that creates the cloud-init ISO file we mentioned before (check the source code of the script for a better understanding of how it's used). Default is **'/data/user-data'**.
* `-m` is used to specify the meta-data file that will be passed as a parameter to the command that creates the cloud-init ISO file we mentioned before (check the source code of the script for a better understanding of how it's used).Default is **'/data/meta-data'**.
* `-n` is used to pass a configuration file that will be used by cloud-init to configure the network for the instance.
* `-i` is used to pass a configuration file that our script will use to modify the network interface managed by VirtualBox that is attached to the instance that will be created from this image.
* `-r` is used to pass a configuration file that our script will use to configure the number of processors and amount of memory that is allocated to our instance by VirtualBox.
* `-o` is used to pass the hostname that will be assigned to our instance. This will also be the name used by VirtualBox to reference our instance.
* `-l` is used to inform which Linux distribution (`debian` or `ubuntu`) configuration files we want to use (notice this is used to specify which folder under [data](/data) is referenced). Default is **'debian'**.
* `-b` is used to specify which base image should be used. This is the image name that was created on VirtualBox when we executed the installation steps from our [last article](create-linux-image.md).
* `-s` is used to pass a configuration file that our script will use to configure virtual disks on VirtualBox. You'll notice this is used only on the Gluster configuration step.
* `-a` whether or not our instance should be initialized after it's created. Default is **true**.

## Running Demo

To initialize and configure our instances using [**`cloud-init`**](/documentation/cloud-init.md), we'll use the configuration files versioned at the [data](/data) directory from our repository.

Note: pay attention that, for each step, we pass the specific configuration files of the component being configured (gate, hapx, glus etc.)

### Create gateway

```shell
./create-image.sh \
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

### Create BusyBox

```shell
./create-image.sh \
    -k ~/.ssh/id_rsa.pub \
    -u busybox/user-data \
    -n busybox/network-config \
    -i busybox/post-config-interfaces \
    -r busybox/post-config-resources \
    -o busybox \
    -l debian \
    -b debian-base-image
```

### Create HAProxy Cluster

```shell
for instance in hapx-node01 hapx-node02; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u hapx/user-data \
        -n hapx/network-config \
        -i hapx/post-config-interfaces \
        -r hapx/post-config-resources \
        -o ${instance} \
        -l debian \
        -b debian-base-image
done
```

### Create Kubernete Masters

```shell
for instance in kube-mast01 kube-mast02 kube-mast03; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u kube/user-data \
        -n kube-mast/network-config \
        -i kube-mast/post-config-interfaces \
        -r kube-mast/post-config-resources \
        -o ${instance} \
        -l debian \
        -b debian-base-image
done
```

### Create Kube Workers

```shell
for instance in kube-node01 kube-node02 kube-node03; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u kube/user-data \
        -n kube-node/network-config \
        -i kube-node/post-config-interfaces \
        -r kube-node/post-config-resources \
        -o ${instance} \
        -l debian \
        -b debian-base-image
done
```

### Create Gluster Nodes

```shell
for instance in glus-node01 glus-node02 glus-node03; do
    ./create-image.sh \
        -k ~/.ssh/id_rsa.pub \
        -u glus/user-data \
        -n glus/network-config \
        -i glus/post-config-interfaces \
        -s glus/post-config-storages \
        -r glus/post-config-resources \
        -o ${instance} \
        -l debian \
        -b debian-base-image
done
```

### Configure your local routing

You need to add the route on your local machine to access the internal network of Virtualbox.

```shell
sudo ip route add 192.168.4.0/24 via 192.168.254.254 dev vboxnet0
```
