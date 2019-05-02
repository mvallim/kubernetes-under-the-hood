# Kubernetes under the hood
<p align="center">
  <img src="documentation/images/under-the-hood.jpg">
</p>

It even includes a SlideShare explaining the reasoning behid it [Kubernetes under the hood journey](https://pt.slideshare.net/MarcosVallim1/kubernetes-under-the-hood-journey/MarcosVallim1/kubernetes-under-the-hood-journey)

## Target Audience
The target audience for this tutorial is someone planning to install a Kubernetes cluster and wants to understand how everything fits together.

## Index
***Atention**: the documentation for this project is being actively improved to explain the demonstrated concepts clearly. If you face any difficulties while following the steps described in the documentation, please open an issue, so we can keep improving it.*

1. [Kubernetes Journey - Up and running out of the cloud](documentation/objective.md)
2. [Common Cluster Architecture](documentation/common-cluster.md)
3. [Technology Stack](documentation/technologies.md)
4. Networking
   - [Services (DNS, DHCP, Gateway, NAT)](documentation/network-services.md)
   - [DNS](documentation/network-dns.md) (under construction)
   - [DHCP](documentation/network-dhcp.md) (under construction)
   - [Gateway](documentation/network-gateway.md) (under construction)
   - [NAT](documentation/network-nat.md) (under construction)
   - [Network and Subnets](documentation/network.md) (under construction)
   - [Segmentation](documentation/network-segmentation.md)
5. Linux Image
   - [Creating the base image](documentation/create-linux-image.md)
   - [cloud-init Bootstrap](documentation/cloud-init.md)
6. [Configuring your station](documentation/configure-your-station.md)
7. [Running VMs](documentation/running-vms.md)
8. [Configuring hosts](documentation/configure-hosts.md)
9. Putting all together
   - [HAProxy Cluster](documentation/haproxy-cluster.md)
   - [Kubernetes](documentation/kube.md)
     - [flannel](documentation/kube-flannel.md)
     - [etcd](documentation/kube-etcd.md)
     - [Masters](documentation/kube-masters.md)
     - [Workers](documentation/kube-workers.md)
     - [Dashboard](documentation/kube-dashboard.md)
     - [Demo Application](documentation/kube-demo-application.md)
     - [Activating LoadBalancer using MetalLB](documentation/kube-metallb.md)
   - [Gluster](documentation/gluster.md) (under construction)
   - [Heketi](documentation/kube-heketi.md) (under construction)

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
