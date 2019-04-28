## Kubernetes Network Model

### Assumptions
* Pods are all able to communicate with one another without the need to use network address translation (NAT).
* Nodes are the machines that run the Kubernetes cluster. These can be either virtual or physical machines, or indeed anything else that is able to run Kubernetes. These nodes are also able to communicate with all the Pods, without the need for NAT.
* Each Pod will see itself with the same IP that other Pods see it as having.

## Overview
<p align="center">
  <img src="images/kube-network-model.png">
</p>

### Master to Worker
![](images/kube-network-model-master-to-worker.png)

### Worker to Worker
![](images/kube-network-model-worker-to-worker.png)

### Intra Node - Pod to Pod
![](images/kube-network-model-pod-to-pod.png)

### Pod to Internet
![](images/kube-network-model-pod-to-internet.png)