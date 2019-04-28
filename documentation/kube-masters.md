## Kube Master
Master components provide the cluster’s control plane. Master components make global decisions about the cluster (for example, scheduling), and detecting and responding to cluster events (starting up a new pod when a replication controller’s ‘replicas’ field is unsatisfied).

Master components can be run on any machine in the cluster. However, for simplicity, set up scripts typically start all master components on the same machine, and do not run user containers on this machine.

### Components

* **Kubelet** - Kubelet gets the configuration of a pod from the API Server and ensures that the described containers are up and running.
* **Docker** - It takes care of downloading the images and starting the containers.
* **etcd** - The etcd reliably stores the configuration data of the Kubernetes cluster, representing the state of the cluster (what nodes exist in the cluster, what pods should be running, which nodes they are running on, and a whole lot more) at any given point of time.
* **API Server** - The API Server validates and configures data for the api objects which include pods, services, replicationcontrollers, and others. The API Server services REST operations and provides the frontend to the cluster’s shared state through which all other components interact.
* **Controller Manager** - The Controller Manager watches the state of the cluster through the API Server watch feature and, when it gets notified, it makes the necessary changes attempting to move the current state towards the desired state. Besides, the Controller Manager performs lifecycle of as namespace, event, terminated-pod, cascading-deletion, node, etc.
* **Scheduler** - The Scheduler watches for unscheduled pods and binds them to nodes via the binding pod subresource API, according to the availability of the requested resources, quality of service requirements, affinity and anti-affinity specifications, and other constraints. Once the pod has a node assigned, the regular behavior of the Kubelet is triggered and the pod and its containers are created.
* **Kube Proxy** - Kube Proxy acts as a network proxy and a load balancer for a service on a single worker node. It takes care of the network routing for TCP and UDP packets.
* **Flannel** - It is a layer 3 network fabric designed for Kubernetes.
* **CoreDNS** - It is the DNS Server of the Kubernetes cluster.
> * More info about **Flannel**: https://github.com/coreos/flannel
> * More info about **CoreDNS**: https://github.com/coredns/coredns

### Overview
<p align="center">
  <img src="images/kube-master-overview.png">
</p>

### Configure

#### kubeadm-config

At this point we need to inform the initial configurations in our K8S cluster.

The **SAN**, **Plane Control EndPoint** and **POD Subnet** information is required.

The Control Plane EndPoint address was defined in the HAProxy Cluster (192.168.4.20) ([see here] (documentation / haproxy-cluster.md)).
The SAN address will be the same as the Control Plane EndPoint.
The CIDR of the PODs will be the range recommended by the Flannel configuration. ([see here] (https://github.com/coreos/flannel/blob/master/Documentation/kube-flannel.yml) search for `net-conf.json`)

Based on the above information we will have a kubeadm-config.yml as below:

```
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable-1.13
apiServer:
  certSANs:
  - "192.168.4.20"
controlPlaneEndpoint: "192.168.4.20:6443"
networking:
  podSubnet: 10.244.0.0/16
```

#### kubeadm init

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
```

Checking the state of nodes

```
kubectl get nodes
```


```
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