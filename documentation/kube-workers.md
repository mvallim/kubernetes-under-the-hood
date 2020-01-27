# How to setup the Workers using `kubeadm` bootstrap

A node is a worker machine in Kubernetes, previously known as a minion. A node may be a VM or physical machine, depending on the cluster. Each node contains the services necessary to run pods and is managed by the master components. The services on a node include the container runtime, kubelet and kube-proxy. 

## Overview

<p align="center">
  <img src="images/kube-worker-overview.png">
</p>

## Components

* **Kubelet** - Kubelet gets the configuration of a pod from the API Server and ensures that the described containers are up and running.
* **Docker** - It takes care of downloading the images and starting the containers.
* **Kube Proxy** - Kube Proxy acts as a network proxy and a load balancer for a service on a single worker node. It takes care of the network routing for TCP and UDP packets.
* **Flannel** - It is a layer 3 network fabric designed for Kubernetes.

> * More info about **Flannel**: https://github.com/coreos/flannel

## Create the VMs

To initialize and configure our instances using cloud-init, we'll use the configuration files versioned at the data directory from our repository.

Notice we also make use of our `create-image.sh` helper script, passing some files from inside the `data/kube/` directory as parameters.

* **Create the Workers**

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

### Parameters

* **`-k`** is used to copy the **public key** from your host to the newly created VM.
* **`-u`** is used to specify the **user-data** file that will be passed as a parameter to the command that creates the cloud-init ISO file we mentioned before (check the source code of the script for a better understanding of how it's used). Default is **`/data/user-data`**.
* **`-m`** is used to specify the **meta-data** file that will be passed as a parameter to the command that creates the cloud-init ISO file we mentioned before (check the source code of the script for a better understanding of how it's used). Default is **`/data/meta-data`**.
* **`-n`** is used to pass a configuration file that will be used by cloud-init to configure the **network** for the instance.
* **`-i`** is used to pass a configuration file that our script will use to modify the **network interface** managed by **VirtualBox** that is attached to the instance that will be created from this image.
* **`-r`** is used to pass a configuration file that our script will use to configure the **number of processors and amount of memory** that is allocated to our instance by **VirtualBox**.
* **`-o`** is used to pass the **hostname** that will be assigned to our instance. This will also be the name used by **VirtualBox** to reference our instance.
* **`-l`** is used to inform which Linux distribution (**debian** or **ubuntu**) configuration files we want to use (notice this is used to specify which folder under data is referenced). Default is **`debian`**.
* **`-b`** is used to specify which **base image** should be used. This is the image name that was created on **VirtualBox** when we executed the installation steps from our [linux image](create-linux-image.md).
* **`-s`** is used to pass a configuration file that our script will use to configure **virtual disks** on **VirtualBox**. You'll notice this is used only on the **Gluster** configuration step.
* **`-a`** whether or not our instance **should be initialized** after it's created. Default is **`true`**.

### Access the BusyBox

We need to get the **BusyBox IP** to access it via ssh

```shell
vboxmanage guestproperty get busybox "/VirtualBox/GuestInfo/Net/0/V4/IP"
```

The responses should look similar to this:

```shell
Value: 192.168.4.57
```

Use the returned value to access.

```shell
ssh debian@192.168.4.57
```

The responses should look similar to this:

```text
Linux busybox 4.9.0-11-amd64 #1 SMP Debian 4.9.189-3+deb9u2 (2019-11-11) x86_64
The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.
Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
```

### Configure

#### Print Join Command

1. Run the following commands to print join command master replicas on cluster:

   ```bash
   ssh kube-mast01

   sudo kubeadm token create --print-join-command
   ```

   The response should look similar to this:

   ```bash
   kubeadm join 192.168.4.20:6443 --token y5uii4.5myd468ieaavd0g6 --discovery-token-ca-cert-hash sha256:d4990d904f85ad8fb2d2bbb2e56b35a8cd0714092b40e3778209a0f1d4fa38b9
   ```

> The last command print the command to you join nodes on cluster, you will use this command to join wokers on cluster

#### Join first Kube Worker

1. Run the following command to join worker on cluster using the join command execute on the step [**`Print Join Command`**](#print-join-command):

   ```bash
   ssh kube-node01

   sudo kubeadm join 192.168.4.20:6443 \
       --token y5uii4.5myd468ieaavd0g6 \
       --discovery-token-ca-cert-hash sha256:d4990d904f85ad8fb2d2bbb2e56b35a8cd0714092b40e3778209a0f1d4fa38b9
   ```

#### Join second Kube Worker

1. Run the following command to join worker on cluster using the join command execute on the step [**`Print Join Command`**](#print-join-command):

   ```bash
   ssh kube-node02

   sudo kubeadm join 192.168.4.20:6443 \
       --token y5uii4.5myd468ieaavd0g6 \
       --discovery-token-ca-cert-hash sha256:d4990d904f85ad8fb2d2bbb2e56b35a8cd0714092b40e3778209a0f1d4fa38b9
   ```

#### Join third Kube Worker

1. Run the following command to join worker on cluster using the join command execute on the step [**`Print Join Command`**](#print-join-command):

   ```bash
   ssh kube-node03

   sudo kubeadm join 192.168.4.20:6443 \
       --token y5uii4.5myd468ieaavd0g6 \
       --discovery-token-ca-cert-hash sha256:d4990d904f85ad8fb2d2bbb2e56b35a8cd0714092b40e3778209a0f1d4fa38b9
   ```

### View stats K8S Cluster

1. Query the state of nodes and pods

   ```bash
   ssh kube-mast01

   kubectl get nodes -o wide

   kubectl get pods -o wide --all-namespaces
   ```

   The responses should look similar to this:

   ```text
   NAME          STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION   CONTAINER-RUNTIME
   kube-mast01   Ready    master   37m   v1.15.6   192.168.1.241   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-mast02   Ready    master   15m   v1.15.6   192.168.1.95    <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-mast03   Ready    master   12m   v1.15.6   192.168.1.133   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-node01   Ready    <none>   69s   v1.15.6   192.168.2.245   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-node02   Ready    <none>   53s   v1.15.6   192.168.2.165   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-node03   Ready    <none>   40s   v1.15.6   192.168.2.194   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   ```

   > All nodes **Ready**

   ```text
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

   > All pods **Running**
