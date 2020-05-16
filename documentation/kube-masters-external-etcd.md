# How to setup the Masters using kubeadm bootstrap with external etcd

Master components provide the cluster’s control plane. Master components make global decisions about the cluster (for example, scheduling), and detecting and responding to cluster events (starting up a new pod when a replication controller’s ‘replicas’ field is unsatisfied).

Master components can be run on any machine in the cluster. However, for simplicity, setup scripts typically start all master components on the same machine, and do not run user containers on this machine.

<p align="center">
  <img src="images/kube-external-etcd.png">
</p>

## Overview

## Components

* **Kubelet** - Kubelet gets the configuration of a pod from the API Server and ensures that the described containers are up and running.
* **Docker** - It takes care of downloading the images and starting the containers.
* **API Server** - The API Server validates and configures data for the API objects, which include pods, services, replication controllers, and others. The API Server services REST operations and provides the frontend to the cluster’s shared state through which all other components interact.
* **Controller Manager** - The Controller Manager watches the state of the cluster through the API Server watch feature and, when it gets notified, it makes the necessary changes, attempting to move the current state towards the desired state. Besides, the Controller Manager performs lifecycle of as namespace, event, terminated-pod, cascading-deletion, node, etc.
* **Scheduler** - The Scheduler watches for unscheduled pods and binds them to nodes via the binding pod subresource API, according to the availability of the requested resources, quality of service requirements, affinity and anti-affinity specifications, and other constraints. Once the pod has a node assigned, the regular behavior of the Kubelet is triggered and the pod and its containers are created.
* **Kube Proxy** - Kube Proxy acts as a network proxy and a load balancer for a service on a single worker node. It takes care of the network routing for TCP and UDP packets.
* **Flannel** - It is a layer 3 network fabric designed for Kubernetes. Check our [previous topic about flannel](kube-flannel.md) for more information.
* **CoreDNS** - It is the DNS Server of the Kubernetes cluster. For more information, check the [CoreDNS official repository](https://github.com/coredns/coredns).

## Create the VMs

To initialize and configure our instances using cloud-init, we'll use the configuration files versioned at the data directory from our repository.

Notice we also make use of our `create-image.sh` helper script, passing some files from inside the `data/kube/` directory as parameters.

* **Create the Masters**

  ```console
  ~/kubernetes-under-the-hood$ for instance in kube-mast01 kube-mast02 kube-mast03; do
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

  **Parameters:**

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

  **Expected output:**

  ```console
  Total translation table size: 0
  Total rockridge attributes bytes: 417
  Total directory bytes: 0
  Path table size(bytes): 10
  Max brk space used 0
  186 extents written (0 MB)
  0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
  Machine has been successfully cloned as "kube-mast01"
  Waiting for VM "kube-mast01" to power on...
  VM "kube-mast01" has been successfully started.
  Total translation table size: 0
  Total rockridge attributes bytes: 417
  Total directory bytes: 0
  Path table size(bytes): 10
  Max brk space used 0
  186 extents written (0 MB)
  0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
  Machine has been successfully cloned as "kube-mast02"
  Waiting for VM "kube-mast02" to power on...
  VM "kube-mast02" has been successfully started.
  Total translation table size: 0
  Total rockridge attributes bytes: 417
  Total directory bytes: 0
  Path table size(bytes): 10
  Max brk space used 0
  186 extents written (0 MB)
  0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
  Machine has been successfully cloned as "kube-mast03"
  Waiting for VM "kube-mast03" to power on...
  VM "kube-mast03" has been successfully started.
  ```

### Configure your local routing

You need to add a route to your local machine to access the internal network of **Virtualbox**.

```console
~$ sudo ip route add 192.168.4.0/27 via 192.168.4.30 dev vboxnet0
~$ sudo ip route add 192.168.4.32/27 via 192.168.4.62 dev vboxnet0
```

### Access the BusyBox

We need to get the **BusyBox IP** to access it via ssh

```console
~$ vboxmanage guestproperty get busybox "/VirtualBox/GuestInfo/Net/0/V4/IP"
```

Expected output:

```console
Value: 192.168.4.57
```

Use the returned value to access.

```cosole
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

### Configure the cluster

1. Create request client certificate to etcd nodes

    ```console
    debian@busybox:~/etcd-certificates$ CN=apiserver-etcd-client SAN= \
        openssl req -newkey rsa:2048 -nodes \
            -keyout apiserver-etcd-client-key.pem \
            -config config.conf \
            -out apiserver-etcd-client-cert.csr
    ```

2. Sing client certificate using your own CA etcd

    ```console
    debian@busybox:~/etcd-certificates$ CN=apiserver-etcd-client SAN= \
        openssl x509 -req \
            -extfile config.conf \
            -extensions user \
            -in apiserver-etcd-client-cert.csr \
            -CA ca-cert.pem \
            -CAkey ca-key.pem \
            -CAcreateserial \
            -out apiserver-etcd-client-cert.pem \
            -days 3650 \
            -sha256
    ```

3. Copy certificates to `kube-mast01`

    ```console
    debian@busybox:~/etcd-certificates$ scp ca-cert.pem apiserver-etcd-client-*.pem kube-mast01:~/.
    ```

#### `kubeadm-config`

At this point, we need to set up our K8S cluster with its initial configuration..

The **SAN**, **Plane Control EndPoint**, **POD Subnet** and **etcd servers** information is required.

* The **Control Plane EndPoint** address was defined in the HAProxy Cluster (192.168.4.20) ([here](/documentation/haproxy-cluster.md)).
* The **SAN address** will be the same as the Control Plane EndPoint.
* The CIDR of the PODs will be the range recommended by the Flannel configuration (search for `net-conf.json` [here](https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel.yml)).
* The **etcd servers** you should pass the etcd information in the kubeadm config file.

Based on the above information, we will have a [`kubeadm-config-external-etcd.yaml`](../master/kubeadm-config-external-etcd.yaml) that looks like this:

```yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable-1.15
apiServer:
  certSANs:
  - "192.168.4.20"
controlPlaneEndpoint: "192.168.4.20:6443"
networking:
  podSubnet: 10.244.0.0/16
etcd:
  external:
    endpoints:
    - https://etcd-node01.kube.demo:2379
    - https://etcd-node02.kube.demo:2379
    - https://etcd-node03.kube.demo:2379
    caFile: /etc/kubernetes/pki/etcd/ca-cert.pem
    certFile: /etc/kubernetes/pki/apiserver-etcd-client-cert.pem
    keyFile: /etc/kubernetes/pki/apiserver-etcd-client-key.pem  
```

#### `kubeadm init`

The kubeadm tool is good if you need:

* A simple way for you to try out Kubernetes, possibly for the first time.
* A way for existing users to automate setting up a cluster and test their application.
* A building block in other ecosystem and/or installer tools with a larger scope.

> Reference: https://kubernetes.io/docs/setup/production-environment/tools/kubeadm/create-cluster-kubeadm/

Setting up a cluster with external etcd nodes is similar to the procedure used for stacked etcd with the exception that you should setup etcd first, and you should pass the etcd information in the kubeadm config file.

1. Move certificates to access `etcd` nodes

    ```console
    debian@busybox:~$ ssh kube-mast01

    debian@kube-mast01:~$ sudo mkdir -p /etc/kubernetes/pki/etcd

    debian@kube-mast01:~$ sudo mv apiserver-etcd-client-*.pem /etc/kubernetes/pki/.

    debian@kube-mast01:~$ sudo mv ca-cert.pem /etc/kubernetes/pki/etcd/.

    debian@kube-mast01:~$ sudo chown -R root:root /etc/kubernetes/pki
    ```

2. Run the following commands to init master node:

   ```console
   debian@busybox:~$ ssh kube-mast01

   debian@kube-mast01:~$ curl --progress-bar https://raw.githubusercontent.com/mvallim/kubernetes-under-the-hood/master/master/kubeadm-config-external-etcd.yaml -o kubeadm-config-external-etcd.yaml

   debian@kube-mast01:~$ sudo kubeadm init --config=kubeadm-config-external-etcd.yaml --upload-certs
   ```

   Expected output:

   ```console
   [init] Using Kubernetes version: v1.15.12
   [preflight] Running pre-flight checks
   [preflight] Pulling images required for setting up a Kubernetes cluster
   [preflight] This might take a minute or two, depending on the speed of your internet connection
   [preflight] You can also perform this action in beforehand using 'kubeadm config images pull'
   [kubelet-start] Writing kubelet environment file with flags to file "/var/lib/kubelet/kubeadm-flags.env"
   [kubelet-start] Writing kubelet configuration to file "/var/lib/kubelet/config.yaml"
   [kubelet-start] Activating the kubelet service
   [certs] Using certificateDir folder "/etc/kubernetes/pki"
   [certs] Generating "ca" certificate and key
   [certs] Generating "apiserver" certificate and key
   [certs] apiserver serving cert is signed for DNS names [kube-mast01 kubernetes kubernetes.default kubernetes.default.svc ubernetes.default.svc.cluster.local] and IPs [10.96.0.1 192.168.1.28 192.168.4.20 192.168.4.20]
   [certs] Generating "apiserver-kubelet-client" certificate and key
   [certs] External etcd mode: Skipping etcd/ca certificate authority generation
   [certs] External etcd mode: Skipping etcd/healthcheck-client certificate authority generation
   [certs] External etcd mode: Skipping apiserver-etcd-client certificate authority generation
   [certs] External etcd mode: Skipping etcd/server certificate authority generation
   [certs] External etcd mode: Skipping etcd/peer certificate authority generation
   [certs] Generating "front-proxy-ca" certificate and key
   [certs] Generating "front-proxy-client" certificate and key
   [certs] Generating "sa" key and public key
   [kubeconfig] Using kubeconfig folder "/etc/kubernetes"
   [kubeconfig] Writing "admin.conf" kubeconfig file
   [kubeconfig] Writing "kubelet.conf" kubeconfig file
   [kubeconfig] Writing "controller-manager.conf" kubeconfig file
   [kubeconfig] Writing "scheduler.conf" kubeconfig file
   [control-plane] Using manifest folder "/etc/kubernetes/manifests"
   [control-plane] Creating static Pod manifest for "kube-apiserver"
   [control-plane] Creating static Pod manifest for "kube-controller-manager"
   [control-plane] Creating static Pod manifest for "kube-scheduler"
   [wait-control-plane] Waiting for the kubelet to boot up the control plane as static Pods from directory "/etc/kubernetes/anifests". This can take up to 4m0s
   [apiclient] All control plane components are healthy after 20.509626 seconds
   [upload-config] Storing the configuration used in ConfigMap "kubeadm-config" in the "kube-system" Namespace
   [kubelet] Creating a ConfigMap "kubelet-config-1.15" in namespace kube-system with the configuration for the kubelets in the luster
   [upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
   [upload-certs] Using certificate key:
   7e5faf2632e924ab1baa6a1fd0cf4fb5243acb5ef0a40c69ed2039cd9468dbb0
   [mark-control-plane] Marking the node kube-mast01 as control-plane by adding the label "node-role.kubernetes.io/master=''"
   [mark-control-plane] Marking the node kube-mast01 as control-plane by adding the taints [node-role.kubernetes.io/master:NoSchedule]
   [bootstrap-token] Using token: 6xy7kn.y6j54yd9gixmz360
   [bootstrap-token] Configuring bootstrap tokens, cluster-info ConfigMap, RBAC Roles
   [bootstrap-token] configured RBAC rules to allow Node Bootstrap tokens to post CSRs in order for nodes to get long term ertificate credentials
   [bootstrap-token] configured RBAC rules to allow the csrapprover controller automatically approve CSRs from a Node Bootstrap Token
   [bootstrap-token] configured RBAC rules to allow certificate rotation for all node client certificates in the cluster
   [bootstrap-token] Creating the "cluster-info" ConfigMap in the "kube-public" namespace
   [addons] Applied essential addon: CoreDNS
   [addons] Applied essential addon: kube-proxy

   Your Kubernetes control-plane has initialized successfully!

   To start using your cluster, you need to run the following as a regular user:

     mkdir -p $HOME/.kube
     sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config
     sudo chown $(id -u):$(id -g) $HOME/.kube/config

   You should now deploy a pod network to the cluster.
   Run "kubectl apply -f [podnetwork].yaml" with one of the options listed at:
     https://kubernetes.io/docs/concepts/cluster-administration/addons/

   You can now join any number of the control-plane node running the following command on each as root:

     kubeadm join 192.168.4.20:6443 --token 5e7aaq.ejvnu55qqxst7czz \
       --discovery-token-ca-cert-hash sha256:457f6e849077f9c0a6ed8ad6517c91bfa4f48080c141dda34c3650fc3b1a99fd \
       --control-plane --certificate-key 039bae4efd18d7692139f1101fedc877f68c1b4f3a7aa247d4703a764cc98131

   Please note that the certificate-key gives access to cluster sensitive data, keep it secret!
   As a safeguard, uploaded-certs will be deleted in two hours; If necessary, you can use
    "kubeadm init phase upload-certs --upload-certs" to reload certs afterward.

   Then you can join any number of worker nodes by running the following on each as root:

   kubeadm join 192.168.4.20:6443 --token 5e7aaq.ejvnu55qqxst7czz \
       --discovery-token-ca-cert-hash sha256:457f6e849077f9c0a6ed8ad6517c91bfa4f48080c141dda34c3650fc3b1a99fd
   ```

3. Finish configuring the cluster and query the state of nodes and pods

   ```console
   debian@kube-mast01:~$ mkdir -p $HOME/.kube

   debian@kube-mast01:~$ sudo cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

   debian@kube-mast01:~$ sudo chown $(id -u):$(id -g) $HOME/.kube/config

   debian@kube-mast01:~$ kubectl get nodes -o wide

   debian@kube-mast01:~$ kubectl get pods -o wide --all-namespaces
   ```

   Expected output:

   ```console
   NAME          STATUS     ROLES    AGE   VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION   CONTAINER-RUNTIME
   kube-mast01   NotReady   master   53s   v1.15.6   192.168.1.72   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   ```

   ```console
   NAMESPACE     NAME                                  READY   STATUS    RESTARTS   AGE   IP             NODE          NOMINATED NODE   READINESS GATES
   kube-system   coredns-86c58d9df4-6gzrk              0/1     Pending   0          89s   <none>         <none>        <none>           <none>
   kube-system   coredns-86c58d9df4-fxj5r              0/1     Pending   0          89s   <none>         <none>        <none>           <none>
   kube-system   kube-apiserver-kube-mast01            1/1     Running   0          43s   192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-controller-manager-kube-mast01   1/1     Running   0          44s   192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-proxy-8kb86                      1/1     Running   0          89s   192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-scheduler-kube-mast01            1/1     Running   0          27s   192.168.1.72   kube-mast01   <none>           <none>
   ```

> If you look at the status on the `kube-mast01` node, it says it is **NotReady** and the `coredns` pods are in the **Pending** state. This is because, up to this point, we do not have a network component configured in our K8S cluster. Remember, as explained before, Flannel will be used for this matter.

#### Deploy flannel

1. Run the following commands to init the flannel network component:

   ```console
   debian@kube-mast01:~$ kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/v0.11.0/Documentation/kube-flannel.yml
   ```

   Expected output:

   ```console
   clusterrole.rbac.authorization.k8s.io/flannel created
   clusterrolebinding.rbac.authorization.k8s.io/flannel created
   serviceaccount/flannel created
   configmap/kube-flannel-cfg created
   daemonset.extensions/kube-flannel-ds-amd64 created
   daemonset.extensions/kube-flannel-ds-arm64 created
   daemonset.extensions/kube-flannel-ds-arm created
   daemonset.extensions/kube-flannel-ds-ppc64le created
   daemonset.extensions/kube-flannel-ds-s390x created
   ```

2. Query the state of the nodes and pods after flannel is deployed:

   ```console
   debian@kube-mast01:~$ kubectl get nodes -o wide

   debian@kube-mast01:~$ kubectl get pods -o wide --all-namespaces
   ```

   Expected output:

   ```console
   NAME          STATUS   ROLES    AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION   CONTAINER-RUNTIME
   kube-mast01   Ready    master   4m30s   v1.15.6   192.168.1.72   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   ```

   ```console
   NAMESPACE     NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
   kube-system   coredns-86c58d9df4-6gzrk              1/1     Running   0          6m4s    10.244.0.4     kube-mast01   <none>           <none>
   kube-system   coredns-86c58d9df4-fxj5r              1/1     Running   0          6m4s    10.244.0.5     kube-mast01   <none>           <none>
   kube-system   kube-apiserver-kube-mast01            1/1     Running   0          5m18s   192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-controller-manager-kube-mast01   1/1     Running   0          5m19s   192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-flannel-ds-amd64-545vl           1/1     Running   0          24s     192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-proxy-8kb86                      1/1     Running   0          6m4s    192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-scheduler-kube-mast01            1/1     Running   0          5m2s    192.168.1.72   kube-mast01   <none>           <none>
   ```

> If you look at the status on the `kube-mast01` node, it is now **Ready** and coredns is **Running**. Also, now there is pod named `kube-flannel-ds-amd64`.

### Join Master Replicas

Now we need to join the other nodes to our K8S cluster. For this, we need the certificates that were generated in the previous steps.

#### Print Certificate Key

1. Run the following commands to copy certificates to master replicas:

   ```console
   debian@kube-mast01:~$ sudo kubeadm init phase upload-certs --upload-certs
   ```

   Expected output:

   ```console
   I0126 20:48:17.259139    5983 version.go:248] remote version is much newer: v1.17.2; falling back to: stable-1.15
   [upload-certs] Storing the certificates in Secret "kubeadm-certs" in the "kube-system" Namespace
   [upload-certs] Using certificate key:
   f385dc122fcaefb52a2c9c748b399b502026ac1c8134cb9b9aa79144d004d95c
   ```

   Now we'll use the certificate key `f385dc122fcaefb52a2c9c748b399b502026ac1c8134cb9b9aa79144d004d95c`

#### Print the Join Command

1. Run the following command to print the join command. This will be used to join the other master replicas to the cluster:

   ```console
   debian@kube-mast01:~$ sudo kubeadm token create --print-join-command
   ```

   Expected output:

   ```console
   kubeadm join 192.168.4.20:6443 --token uziz9q.5n9r0rbempgyupvg --discovery-token-ca-cert-hash sha256:457f6e849077f9c0a6ed8ad6517c91bfa4f48080c141dda34c3650fc3b1a99fd
   ```

#### Join the second Kube Master

1. Run the following commands to join the second master replica to cluster using the join command printed in the previous section:

   ```console
   debian@busybox:~$ ssh kube-mast02

   debian@kube-mast02:~$ sudo kubeadm join 192.168.4.20:6443 \
      --token uziz9q.5n9r0rbempgyupvg \
      --discovery-token-ca-cert-hash sha256:457f6e849077f9c0a6ed8ad6517c91bfa4f48080c141dda34c3650fc3b1a99fd \
      --certificate-key f385dc122fcaefb52a2c9c748b399b502026ac1c8134cb9b9aa79144d004d95c \
      --control-plane
   ```

#### Join third Kube Master

1. Run the following commands to join the third master replica to cluster using the join command printed in the previous section:

   ```console
   debian@busybox:~$ ssh kube-mast03

   debian@kube-mast03:~$ sudo kubeadm join 192.168.4.20:6443 \
      --token uziz9q.5n9r0rbempgyupvg \
      --discovery-token-ca-cert-hash sha256:457f6e849077f9c0a6ed8ad6517c91bfa4f48080c141dda34c3650fc3b1a99fd \
      --certificate-key f385dc122fcaefb52a2c9c748b399b502026ac1c8134cb9b9aa79144d004d95c \
      --control-plane
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
   NAME          STATUS   ROLES    AGE     VERSION   INTERNAL-IP    EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION   CONTAINER-RUNTIME
   kube-mast01   Ready    master   34m     v1.15.6   192.168.1.72   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-mast02   Ready    master   4m34s   v1.15.6   192.168.1.68   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-mast03   Ready    master   2m54s   v1.15.6   192.168.1.81   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   ```

   > All master nodes are expected to be in the **Ready** state:

   ```console
   NAMESPACE     NAME                                  READY   STATUS    RESTARTS   AGE     IP             NODE          NOMINATED NODE   READINESS GATES
   kube-system   coredns-86c58d9df4-6gzrk              1/1     Running   0          34m     10.244.0.4     kube-mast01   <none>           <none>
   kube-system   coredns-86c58d9df4-fxj5r              1/1     Running   0          34m     10.244.0.5     kube-mast01   <none>           <none>
   kube-system   kube-apiserver-kube-mast01            1/1     Running   0          34m     192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-apiserver-kube-mast02            1/1     Running   1          5m22s   192.168.1.68   kube-mast02   <none>           <none>
   kube-system   kube-apiserver-kube-mast03            1/1     Running   0          2m57s   192.168.1.81   kube-mast03   <none>           <none>
   kube-system   kube-controller-manager-kube-mast01   1/1     Running   1          34m     192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-controller-manager-kube-mast02   1/1     Running   0          5m22s   192.168.1.68   kube-mast02   <none>           <none>
   kube-system   kube-controller-manager-kube-mast03   1/1     Running   0          3m42s   192.168.1.81   kube-mast03   <none>           <none>
   kube-system   kube-flannel-ds-amd64-545vl           1/1     Running   0          29m     192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-flannel-ds-amd64-gnngz           1/1     Running   0          3m42s   192.168.1.81   kube-mast03   <none>           <none>
   kube-system   kube-flannel-ds-amd64-trxc2           1/1     Running   0          5m22s   192.168.1.68   kube-mast02   <none>           <none>
   kube-system   kube-proxy-8kb86                      1/1     Running   0          34m     192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-proxy-cpspc                      1/1     Running   0          3m42s   192.168.1.81   kube-mast03   <none>           <none>
   kube-system   kube-proxy-j6sch                      1/1     Running   0          5m22s   192.168.1.68   kube-mast02   <none>           <none>
   kube-system   kube-scheduler-kube-mast01            1/1     Running   1          33m     192.168.1.72   kube-mast01   <none>           <none>
   kube-system   kube-scheduler-kube-mast02            1/1     Running   0          5m22s   192.168.1.68   kube-mast02   <none>           <none>
   kube-system   kube-scheduler-kube-mast03            1/1     Running   0          3m42s   192.168.1.81   kube-mast03   <none>           <none>
   ```

   > All master pods **Running**

### Check the HAProxy Cluster stats

Open your browser at [http://192.168.4.20:32700](http://192.168.4.20:32700)

User: `admin`  
Password: `admin`

It will show:

It will show:
<p align="center">
  <img src="images/haproxy-cluster-stats-masters.png">
</p>

Notice all Control Plane EndPoints are now *UP*

* kube-mast01:6443
* kube-mast02:6443
* kube-mast03:6443
