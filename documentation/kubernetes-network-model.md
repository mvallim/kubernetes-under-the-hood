## Kubernetes Network Model

## Overview
<p align="center">
  <img src="images/kube-network-model.png">
</p>

### Assumptions
* Pods are all able to communicate with one another without the need to use network address translation (NAT).
* Nodes are the machines that run the Kubernetes cluster. These can be either virtual or physical machines, or indeed anything else that is able to run Kubernetes. These nodes are also able to communicate with all the Pods, without the need for NAT.
* Each Pod will see itself with the same IP that other Pods see it as having.

#### Master to Worker
![](images/kube-network-model-master-to-worker)

#### Worker to Worker

#### Intra Node - Pod to Pod

#### Pod to Internet