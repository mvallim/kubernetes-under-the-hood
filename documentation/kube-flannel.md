## Flannel
*“Flannel is a simple and easy way to configure a layer 3 network fabric designed for Kubernetes.*
*Flannel runs a small, single binary agent called flanneld on each host, and is responsible for allocating a subnet lease to each host out of a larger, preconfigured address space. Flannel uses either the Kubernetes API or etcd directly to store the network configuration, the allocated subnets, and any auxiliary data (such as the host's public IP). Packets are forwarded using one of several backend mechanisms including VXLAN and various cloud integrations.”*

You can see Kubernetes Network Model [here](/documentation/kube-network-model.md)