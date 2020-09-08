# How to setup the Workers using `kubeadm` bootstrap

A node is a worker machine in Kubernetes, previously known as a minion. A node may be a VM or physical machine, depending on the cluster. Each node contains the services necessary to run pods and is managed by the master components. The services on a node include the container runtime, kubelet and kube-proxy.

## Overview

<p align="center">
  <img src="images/kube-worker-overview.png">
</p>

## Components

- **Kubelet** - Gets configuration of a pod from the API Server and ensures that the described containers are up and running.
- **Docker** - Takes care of downloading the images and starting the containers.
- **Kube Proxy** - Acts as a network proxy and a load balancer for a service on a single worker node. It takes care of the network routing for TCP and UDP packets.
- **Flannel** - A layer 3 network fabric designed for Kubernetes. Check our [previous topic about flannel](kube-flannel.md) for more information.

> - More info about **Flannel**: https://github.com/coreos/flannel

## Create the VMs

To initialize and configure our instances using cloud-init, we'll use the configuration files versioned at the data directory from our repository.

Notice we also make use of our [`create-image.sh`](../create-image.sh) helper script, passing some files from inside the `data/kube/` directory as parameters.

- **Create the Workers**

  ```console
  ~/kubernetes-under-the-hood$ for instance in kube-node01 kube-node02 kube-node03; do
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

  Expected output:

  ```console
  Total translation table size: 0
  Total rockridge attributes bytes: 417
  Total directory bytes: 0
  Path table size(bytes): 10
  Max brk space used 0
  186 extents written (0 MB)
  0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
  Machine has been successfully cloned as "kube-node01"
  Waiting for VM "kube-node01" to power on...
  VM "kube-node01" has been successfully started.
  Total translation table size: 0
  Total rockridge attributes bytes: 417
  Total directory bytes: 0
  Path table size(bytes): 10
  Max brk space used 0
  186 extents written (0 MB)
  0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
  Machine has been successfully cloned as "kube-node02"
  Waiting for VM "kube-node02" to power on...
  VM "kube-node02" has been successfully started.
  Total translation table size: 0
  Total rockridge attributes bytes: 417
  Total directory bytes: 0
  Path table size(bytes): 10
  Max brk space used 0
  186 extents written (0 MB)
  0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
  Machine has been successfully cloned as "kube-node03"
  Waiting for VM "kube-node03" to power on...
  VM "kube-node03" has been successfully started.
  ```

  **Parameters:**

  - **`-k`** is used to copy the **public key** from your host to the newly created VM.
  - **`-u`** is used to specify the **user-data** file that will be passed as a parameter to the command that creates the cloud-init ISO file we mentioned before (check the source code of the script for a better understanding of how it's used). Default is **`/data/user-data`**.
  - **`-m`** is used to specify the **meta-data** file that will be passed as a parameter to the command that creates the cloud-init ISO file we mentioned before (check the source code of the script for a better understanding of how it's used). Default is **`/data/meta-data`**.
  - **`-n`** is used to pass a configuration file that will be used by cloud-init to configure the **network** for the instance.
  - **`-i`** is used to pass a configuration file that our script will use to modify the **network interface** managed by **VirtualBox** that is attached to the instance that will be created from this image.
  - **`-r`** is used to pass a configuration file that our script will use to configure the **number of processors and amount of memory** that is allocated to our instance by **VirtualBox**.
  - **`-o`** is used to pass the **hostname** that will be assigned to our instance. This will also be the name used by **VirtualBox** to reference our instance.
  - **`-l`** is used to inform which Linux distribution (**debian** or **ubuntu**) configuration files we want to use (notice this is used to specify which folder under data is referenced). Default is **`debian`**.
  - **`-b`** is used to specify which **base image** should be used. This is the image name that was created on **VirtualBox** when we executed the installation steps from our [linux image](create-linux-image.md).
  - **`-s`** is used to pass a configuration file that our script will use to configure **virtual disks** on **VirtualBox**. You'll notice this is used only on the **Gluster** configuration step.
  - **`-a`** whether or not our instance **should be initialized** after it's created. Default is **`true`**.

### Configure your local routing

You need to add a route to your local machine to access the internal network of **Virtualbox**.

```console
~$ sudo ip route add 192.168.4.0/27 via 192.168.4.30 dev vboxnet0
~$ sudo ip route add 192.168.4.32/27 via 192.168.4.62 dev vboxnet0
```

### Access the BusyBox

We need to get the **BusyBox IP** to access it via ssh:

```console
~$ vboxmanage guestproperty get busybox "/VirtualBox/GuestInfo/Net/0/V4/IP"
```

Expected output:

```console
Value: 192.168.4.57
```

Use the returned value to access the BusyBox:

```console
~$ ssh debian@192.168.4.57
```

Expected output:

```console
Linux busybox 4.9.0-11-amd64 #1 SMP Debian 4.9.189-3+deb9u2 (2019-11-11) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
```

### Understading the user-data file

The cloud-init kube-master configuration file can be found [here](/data/debian/kube/user-data). This configures and install docker and kubernetes biniaries (kubeadm, kubectl, kublet).

Below you can find the same file commented for easier understanding:

```yaml
#cloud-config
write_files:
  # CA ssh pub certificate
  - path: /etc/ssh/ca.pub
    permissions: "0644"
    encoding: b64
    content: |
      c3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFDQVFERGozaTNSODZvQzNzZ0N3ZVRh
      R1dHZVZHRFpLbFdiOHM4QWVJVE9hOTB3NHl5UndSUWtBTWNGaWFNWGx5OEVOSDd0MHNpM0tFYnRZ
      M1B1ekpTNVMwTHY0MVFkaHlYMHJhUGxobTZpNnVDV3BvYWsycEF6K1ZFazhLbW1kZjdqMm5OTHlG
      Y3NQeVg0b0t0SlQrajh6R2QxWHRBWDBuS0JWOXFkOGNTTFFBZGpQVkdNZGxYdTNCZzdsNml3OHhK
      Ti9ld1l1Qm5DODZ5TlNiWFlDVVpLOE1oQUNLV2FMVWVnOSt0dXNyNTBSbGVRcGI0a2NKRE45LzFa
      MjhneUtORTRCVENYanEyTzVqRE1MRDlDU3hqNXJoNXRPUUlKREFvblIrMnljUlVnZTltc2hIQ05D
      VWU2WG16OFVJUFJ2UVpPNERFaHpHZ2N0cFJnWlhQajRoMGJoeGVMekUxcFROMHI2Q29GMDVpOFB0
      QXd1czl1K0tjUHVoQlgrVm9UbW1JNmRBTStUQkxRUnJ3SUorNnhtM29nWEMwYVpjdkdCVUVTcVll
      QjUyU0xjZEwyNnBKUlBrVjZYQ0Qyc3RleG5uOFREUEdjYnlZelFnaGNlYUYrb0psdWE4UDZDSzV2
      VStkNlBGK2o1aEE2NGdHbDQrWmw0TUNBcXdNcnBySEhpd2E3bzF0MC9JTmdoYlFvUUdSU3haQXMz
      UHdYcklMQ0xUeGN6V29UWHZIWUxuRXRTWW42MVh3SElldWJrTVhJamJBSysreStKWCswcm02aHRN
      N2h2R2QzS0ZvU1N4aDlFY1FONTNXWEhMYXBHQ0o0NGVFU3NqbVgzN1NwWElUYUhEOHJQRXBia0E0
      WWJzaVVoTXZPZ0VCLy9MZ1d0R2kvRVRxalVSUFkvWGRTVTR5dFE9PSBjYUBrdWJlLmRlbW8K

  # The bridge-netfilter code enables the following functionality:
  #  - {Ip,Ip6,Arp}tables can filter bridged IPv4/IPv6/ARP packets, even when
  # encapsulated in an 802.1Q VLAN or PPPoE header. This enables the functionality
  # of a stateful transparent firewall.
  #  - All filtering, logging and NAT features of the 3 tools can therefore be used
  # on bridged frames.
  #  - Combined with ebtables, the bridge-nf code therefore makes Linux a very
  # powerful transparent firewall.
  #  - This enables, f.e., the creation of a transparent masquerading machine (i.e.
  # all local hosts think they are directly connected to the Internet).
  - path: /etc/modules-load.d/bridge.conf
    permissions: "0644"
    content: |
      br_netfilter

  # Besides providing the NetworkPlugin interface to configure and clean up pod networking,
  # the plugin may also need specific support for kube-proxy. The iptables proxy obviously
  # depends on iptables, and the plugin may need to ensure that container traffic is made
  # available to iptables. For example, if the plugin connects containers to a Linux bridge,
  # the plugin must set the net/bridge/bridge-nf-call-iptables sysctl to 1 to ensure that
  # the iptables proxy functions correctly. If the plugin does not use a Linux bridge
  # (but instead something like Open vSwitch or some other mechanism) it should ensure
  # container traffic is appropriately routed for the proxy.
  #
  # For more details : https://kubernetes.io/docs/concepts/extend-kubernetes/compute-storage-net/network-plugins/#network-plugin-requirements
  #
  # As a requirement for your Linux Node’s iptables to correctly see bridged traffic
  - path: /etc/sysctl.d/10-kubernetes.conf
    permissions: "0644"
    content: |
      net.ipv4.ip_forward=1
      net.bridge.bridge-nf-call-iptables=1
      net.bridge.bridge-nf-call-arptables=1

  # Set up the Docker daemon
  - path: /etc/docker/daemon.json
    permissions: "0644"
    content: |
      {
        "exec-opts": ["native.cgroupdriver=systemd"],
        "log-driver": "json-file",
        "storage-driver": "overlay2",
        "log-opts": {
          "max-size": "100m"
        }
      }

apt:
  sources_list: |
    deb http://deb.debian.org/debian/ $RELEASE main contrib non-free
    deb-src http://deb.debian.org/debian/ $RELEASE main contrib non-free

    deb http://deb.debian.org/debian/ $RELEASE-updates main contrib non-free
    deb-src http://deb.debian.org/debian/ $RELEASE-updates main contrib non-free

    deb http://deb.debian.org/debian-security $RELEASE/updates main
    deb-src http://deb.debian.org/debian-security $RELEASE/updates main
  conf: |
    APT {
      Get {
        Assume-Yes "true";
        Fix-Broken "true";
      };
    };

packages:
  - apt-transport-https
  - ca-certificates
  - gnupg2
  - software-properties-common
  - glusterfs-client
  - bridge-utils
  - curl

runcmd:
  - [modprobe, br_netfilter]
  - [sysctl, --system]
  - curl -s https://download.docker.com/linux/debian/gpg | apt-key add -
  - curl -s https://packages.cloud.google.com/apt/doc/apt-key.gpg | apt-key add -
  - [apt-key, fingerprint, "0EBFCD88"]
  - echo 'deb [arch=amd64] https://download.docker.com/linux/debian stretch stable' > /etc/apt/sources.list.d/docker-ce.list
  - echo 'deb https://apt.kubernetes.io/ kubernetes-xenial main' > /etc/apt/sources.list.d/kubernetes.list
  - [apt-get, update]
  - [apt-get, install, -y, "docker-ce=18.06.0~ce~3-0~debian", containerd.io]
  - [
      apt-get,
      install,
      -y,
      "kubelet=1.15.6-00",
      "kubectl=1.15.6-00",
      "kubeadm=1.15.6-00",
    ]
  - [apt-mark, hold, kubelet, kubectl, kubeadm, docker-ce, containerd.io]
  - [chown, -R, "debian:debian", "/home/debian"]
    # SSH server to trust the CA
  - echo '\nTrustedUserCAKeys /etc/ssh/ca.pub' | tee -a /etc/ssh/sshd_config

users:
  - name: debian
    gecos: Debian User
    sudo: ALL=(ALL) NOPASSWD:ALL
    shell: /bin/bash
    lock_passwd: true
  - name: root
    lock_passwd: true

locale: en_US.UTF-8

timezone: UTC

ssh_deletekeys: 1

package_upgrade: true

ssh_pwauth: true

manage_etc_hosts: true

fqdn: #HOSTNAME#.kube.demo

hostname: #HOSTNAME#

power_state:
  mode: reboot
  timeout: 30
  condition: true
```

### Configure the cluster

#### Print the `Join` Command

1. Run the following commands to print the `join` command master replicas on cluster:

   ```console
   debian@busybox:~$ ssh kube-mast01

   debian@kube-mast01:~$ sudo kubeadm token create --print-join-command
   ```

   Expected output:

   ```console
   kubeadm join 192.168.4.20:6443 --token y5uii4.5myd468ieaavd0g6 --discovery-token-ca-cert-hash sha256:d4990d904f85ad8fb2d2bbb2e56b35a8cd0714092b40e3778209a0f1d4fa38b9
   ```

> The command output prints the command to you join nodes on cluster. You will use this command to join the workers in the cluster.

#### Join the first Kube Worker

1. Run the following commands to join the **first worker** in the cluster using the join command printed in the previous section:

```console
debian@busybox:~$ ssh kube-node01

debian@kube-node01:~$ sudo kubeadm join 192.168.4.20:6443 \
    --token y5uii4.5myd468ieaavd0g6 \
    --discovery-token-ca-cert-hash sha256:d4990d904f85ad8fb2d2bbb2e56b35a8cd0714092b40e3778209a0f1d4fa38b9
```

#### Join the second Kube Worker

1. Run the following commands to join the **second worker** in the cluster using the join command printed in the previous section:

   ```console
   debian@busybox:~$ ssh kube-node02

   debian@kube-node02:~$ sudo kubeadm join 192.168.4.20:6443 \
       --token y5uii4.5myd468ieaavd0g6 \
       --discovery-token-ca-cert-hash sha256:d4990d904f85ad8fb2d2bbb2e56b35a8cd0714092b40e3778209a0f1d4fa38b9
   ```

#### Join the third Kube Worker

1. Run the following commands to join the **third worker** in the cluster using the join command printed in the previous section:

   ```console
   debian@busybox:~$ ssh kube-node03

   debian@kube-node03:~$ sudo kubeadm join 192.168.4.20:6443 \
       --token y5uii4.5myd468ieaavd0g6 \
       --discovery-token-ca-cert-hash sha256:d4990d904f85ad8fb2d2bbb2e56b35a8cd0714092b40e3778209a0f1d4fa38b9
   ```

### Check the K8S Cluster stats

1. Query the state of nodes and pods

   ```console
   debian@busybox:~$ ssh kube-mast01

   debian@kube-mast01:~$ kubectl get nodes -o wide

   debian@kube-mast01:~$ kubectl get pods -o wide --all-namespaces
   ```

   Expected output:

   ```console
   NAME          STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION   CONTAINER-RUNTIME
   kube-mast01   Ready    master   37m   v1.15.6   192.168.1.241   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-mast02   Ready    master   15m   v1.15.6   192.168.1.95    <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-mast03   Ready    master   12m   v1.15.6   192.168.1.133   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-node01   Ready    <none>   69s   v1.15.6   192.168.2.245   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-node02   Ready    <none>   53s   v1.15.6   192.168.2.165   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-node03   Ready    <none>   40s   v1.15.6   192.168.2.194   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   ```

   > All nodes are **Ready**

   ```console
   NAMESPACE     NAME                                  READY   STATUS    RESTARTS   AGE   IP              NODE          NOMINATED NODE   READINESS GATES
   kube-system   coredns-5c98db65d4-mv7lk              1/1     Running   0          36m   10.244.0.2      kube-mast01   <none>           <none>
   kube-system   coredns-5c98db65d4-x4g8r              1/1     Running   0          36m   10.244.0.4      kube-mast01   <none>           <none>
   kube-system   etcd-kube-mast01                      1/1     Running   0          35m   192.168.1.241   kube-mast01   <none>           <none>
   kube-system   etcd-kube-mast02                      1/1     Running   0          15m   192.168.1.95    kube-mast02   <none>           <none>
   kube-system   etcd-kube-mast03                      1/1     Running   0          11m   192.168.1.133   kube-mast03   <none>           <none>
   kube-system   kube-apiserver-kube-mast01            1/1     Running   0          35m   192.168.1.241   kube-mast01   <none>           <none>
   kube-system   kube-apiserver-kube-mast02            1/1     Running   0          15m   192.168.1.95    kube-mast02   <none>           <none>
   kube-system   kube-apiserver-kube-mast03            1/1     Running   0          11m   192.168.1.133   kube-mast03   <none>           <none>
   kube-system   kube-controller-manager-kube-mast01   1/1     Running   1          35m   192.168.1.241   kube-mast01   <none>           <none>
   kube-system   kube-controller-manager-kube-mast02   1/1     Running   0          15m   192.168.1.95    kube-mast02   <none>           <none>
   kube-system   kube-controller-manager-kube-mast03   1/1     Running   0          11m   192.168.1.133   kube-mast03   <none>           <none>
   kube-system   kube-flannel-ds-amd64-6b7tx           1/1     Running   0          42s   192.168.2.165   kube-node02   <none>           <none>
   kube-system   kube-flannel-ds-amd64-bdfdb           1/1     Running   0          11m   192.168.1.133   kube-mast03   <none>           <none>
   kube-system   kube-flannel-ds-amd64-gx7gw           1/1     Running   0          15m   192.168.1.95    kube-mast02   <none>           <none>
   kube-system   kube-flannel-ds-amd64-k5m89           1/1     Running   0          29s   192.168.2.194   kube-node03   <none>           <none>
   kube-system   kube-flannel-ds-amd64-rk78k           1/1     Running   0          33m   192.168.1.241   kube-mast01   <none>           <none>
   kube-system   kube-flannel-ds-amd64-ttt79           1/1     Running   0          58s   192.168.2.245   kube-node01   <none>           <none>
   kube-system   kube-proxy-46bmf                      1/1     Running   0          36m   192.168.1.241   kube-mast01   <none>           <none>
   kube-system   kube-proxy-5grsd                      1/1     Running   0          58s   192.168.2.245   kube-node01   <none>           <none>
   kube-system   kube-proxy-5kmx5                      1/1     Running   0          15m   192.168.1.95    kube-mast02   <none>           <none>
   kube-system   kube-proxy-5z48t                      1/1     Running   0          42s   192.168.2.165   kube-node02   <none>           <none>
   kube-system   kube-proxy-dv9s4                      1/1     Running   0          29s   192.168.2.194   kube-node03   <none>           <none>
   kube-system   kube-proxy-pkblq                      1/1     Running   0          11m   192.168.1.133   kube-mast03   <none>           <none>
   kube-system   kube-scheduler-kube-mast01            1/1     Running   1          35m   192.168.1.241   kube-mast01   <none>           <none>
   kube-system   kube-scheduler-kube-mast02            1/1     Running   0          15m   192.168.1.95    kube-mast02   <none>           <none>
   kube-system   kube-scheduler-kube-mast03            1/1     Running   0          11m   192.168.1.133   kube-mast03   <none>           <none>
   ```

   > All pods are **Running**
