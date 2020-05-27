# Kubernetes under the hood

<p align="center">
  <img src="documentation/images/under-the-hood.jpg">
</p>

It even includes a SlideShare explaining the reasoning behid it [Kubernetes under the hood journey](https://pt.slideshare.net/MarcosVallim1/kubernetes-under-the-hood-journey/MarcosVallim1/kubernetes-under-the-hood-journey)

## Target Audience

The target audience for this tutorial is someone planning to install a Kubernetes cluster and wants to understand how everything fits together.

## Index

***Atention**: the documentation for this project is being actively improved to explain the demonstrated concepts clearly. If you face any difficulties while following the steps described in the documentation, please open an issue, so we can keep improving it. The version of Kubernetes used here is **1.15.6***

1. Introdution
   - [Up and running out of the cloud](documentation/objective.md)
2. Planning
   - [Architecture Overview](documentation/common-cluster.md)
   - [Technology Stack](documentation/technologies.md)
   - [Networking](documentation/networking.md)
3. Kubernetes
   - [Overview](documentation/kube-overview.md)
   - [Masters and Workers](documentation/kube-masters-and-workers.md)
   - [etcd](documentation/kube-etcd.md)
   - [flannel](documentation/kube-flannel.md)
   - [Linux image](documentation/linux-image.md)
4. Putting all together
   1. [How to setup the Debian Linux image from scratch](documentation/create-linux-image.md)
   2. [How to setup the Gateway and Busybox components](documentation/starting-setup.md)
   3. [How to setup the HAProxy Cluster with high availability](documentation/haproxy-cluster.md)
   4. [How to setup the Masters using `kubeadm` bootstrap](documentation/kube-masters.md)
   5. [How to setup the Workers using `kubeadm` bootstrap](documentation/kube-workers.md)
   6. [How to setup the Dashboard](documentation/kube-dashboard.md)
   7. [Demo Application](documentation/kube-demo-application.md)
   8. LoadBalancer
      - [How to setup the MetalLB](documentation/kube-metallb.md)
   9. Volumes
      - [How to setup storage GlusterFS](documentation/gluster.md) (under construction)
5. External CA Infrastructure
   1. [How to create the external CA Infrastructure](documentation/ca-external-infrastructure.md) (under construction)
6. External `etcd`
   1. [How to setup the external etcd with TLS](documentation/etcd.md)
   2. [How to setup the Masters using `kubeadm` bootstrap with external `etcd`](documentation/kube-masters-external-etcd.md)

## Contributing

Please read [CONTRIBUTING.md](CONTRIBUTING.md) for details on our code of conduct, and the process for submitting pull requests to us.

## Versioning

We use [GitHub](https://github.com/mvallim/kubernetes-under-the-hood) for versioning. For the versions available, see the [tags on this repository](https://github.com/mvallim/kubernetes-under-the-hood/tags).

## Authors

- **Marcos Vallim** - *Initial work, Development, Test, Documentation* - [mvallim](https://github.com/mvallim)
- **Fabio Franco Uechi** - *Validation demo* - [fabito](https://github.com/fabito)
- **Dirceu Alves Silva** - *Validation demo* - [dirceusilva](https://github.com/dirceuSilva)
- **Leandro Nunes Fantinatto** - *Validation demo* - [lnfnunes](https://github.com/lnfnunes)
- **Ivam dos Santos Luz** - *Validation demo, Articles* - [ivamluz](https://github.com/ivamluz)
- **Marcos de Lima Goncalves** - *Validation demo, Presentation Organizer* - [marcoslimagon](https://github.com/marcoslimagon)
- **Murilo Woigt Miranda** - *Validation demo, Presentation Organizer* - [woigt-ciandt](https://github.com/woigt-ciandt)

See also the list of [contributors](CONTRIBUTORS.txt) who participated in this project.

## License

This project is licensed under the BSD License - see the [LICENSE](LICENSE) file for details
