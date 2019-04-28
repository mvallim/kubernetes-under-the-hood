## HAProxy
HAProxy is a free, very fast and reliable solution offering high availability, load balancing, and proxying for TCP and HTTP-based applications. It is particularly suited for very high traffic web sites and powers quite a number of the world's most visited ones. Over the years it has become the de-facto standard opensource load balancer, is now shipped with most mainstream Linux distributions, and is often deployed by default in cloud platforms. Since it does not advertise itself, we only know it's used when the admins report it :-)
> More details: http://www.haproxy.org/

## Corosync
The Corosync Cluster Engine is a Group Communication System with additional features for implementing high availability within applications. The project provides four C Application Programming Interface features:
* A closed process group communication model with extended virtual synchrony guarantees for creating replicated state machines.
* A simple availability manager that restarts the application process when it has failed.
* A configuration and statistics in-memory database that provide the ability to set, retrieve, and receive change notifications of information.
* A quorum system that notifies applications when quorum is achieved or lost.
> More details: http://corosync.github.io/corosync/

## Pacemaker
Pacemaker is an Open Source, High Availability resource manager suitable for both small and large clusters.
> More details: https://clusterlabs.org/pacemaker/

## Solution
<p align="center">
  <img src="images/haproxy-cluster.gif">
</p>

## Definitions and Configure

### ocf`:heartbeat:IPaddr2
This Linux-specific resource manages IP alias IP addresses. It can add an IP alias, or remove one. In addition, it can implement Cluster Alias IP functionality if invoked as a clone resource.
> More info about ocf:heartbeat:IPaddr2: http://linux-ha.org/doc/man-pages/re-ra-IPaddr2.html

### ocf`:heartbeat:haproxy
Manages haproxy daemon as an OCF resource in an High Availability setup.
> More info about ocf:heartbeat:haproxy: https://raw.githubusercontent.com/russki/cluster-agents/master/haproxy

### Configure

We will define here that our Virtual IP will be 192.168.4.20, ip of the K8S cluster (Control Plane EndPoint).

The HAProxy configuration cloud-init can be found [here](/data/debian/hapx/user-data), which correspond to doing a Load Balance for the Kube Master Nodes.

At this point we will configure the features of our HAProxy Cluster using [crmsh](https://crmsh.github.io/)

```
ssh debian@hapx-node01.kube.local

sudo crm configure

property stonith-enabled=no
property no-quorum-policy=ignore
property default-resource-stickiness=100
primitive virtual-ip-resource ocf:heartbeat:IPaddr2 params ip="192.168.4.20" nic="enp0s3" cidr_netmask="32" meta migration-threshold=2 op monitor interval=20 timeout=60 on-fail=restart
primitive haproxy-resource ocf:heartbeat:haproxy op monitor interval=20 timeout=60 on-fail=restart
colocation loc inf: virtual-ip-resource haproxy-resource
order ord inf: virtual-ip-resource haproxy-resource
commit
bye
```

### View stats HAProxy
Open your browser with address [http://192.168.4.20:32700](http://192.168.4.20:32700)

User: admin
Password: admin

It will show:
![](images/haproxy-cluster-stats.png)

All Control Plane EndPoints *DOWN*

* kube-mast01:6443
* kube-mast02:6443
* kube-mast03:6443

### Test High Availability 
Shutdown one of the two VMs (hapx-node01 or hapx-node02) and press F5 in your browser, where you have opened the HAProxy statistics. No difference or error should occur. :)
