## Kube Workers

### Components

* **Kubelet** - Kubelet gets the configuration of a pod from the API Server and ensures that the described containers are up and running.
* **Docker** - It takes care of downloading the images and starting the containers.
* **Kube Proxy** - Kube Proxy acts as a network proxy and a load balancer for a service on a single worker node. It takes care of the network routing for TCP and UDP packets.
* **Flannel** - It is a layer 3 network fabric designed for Kubernetes.
> * More info about **Flannel**: https://github.com/coreos/flannel

### Overview
<p align="center">
  <img src="images/kube-worker-overview.png">
</p>

### Configure

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