# How to setup the MetalLB

<p align="center">
  <img src="images/metallb-logo.png">
</p>

*“MetalLB is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.”*

> Reference: https://metallb.universe.tf/

## Why

*Kubernetes does not offer an implementation of network load-balancers (Services of type LoadBalancer) for bare metal clusters. The implementations of Network LB that Kubernetes does ship with are all glue code that calls out to various IaaS platforms (GCP, AWS, Azure…). If you’re not running on a supported IaaS platform (GCP, AWS, Azure…), Load Balancers will remain in the “pending” state indefinitely when created.*

## Configure your local routing

You need to add a route to your local machine to access the internal network of **Virtualbox**.

```console
~$ sudo ip route add 192.168.4.0/27 via 192.168.4.30 dev vboxnet0
~$ sudo ip route add 192.168.4.32/27 via 192.168.4.62 dev vboxnet0
~$ sudo ip route add 192.168.2.0/24 via 192.168.4.254 dev vboxnet0
```

## Access the BusyBox

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

## Install

### `kube-service-load-balancer`

LoadBalancer manifest:

```yaml
apiVersion: v1
kind: Service
metadata:  
  name: load-balancer-service
spec:
  selector:
    app: guestbook
    tier: frontend
  type: LoadBalancer
  ports:  
  - name: http
    port: 80
    targetPort: 80
    protocol: TCP
```

1. Apply the LoadBalancer service deploy from the [`kube-service-load-balancer`](../services/kube-service-load-balancer.yaml) file:

   ```console
   debian@busybox:~$ kubectl apply -f https://raw.githubusercontent.com/mvallim/kubernetes-under-the-hood/master/services/kube-service-load-balancer.yaml
   ```

   The response should look similar to this:

   ```text
   service/load-balancer-service created
   ```

2. Query the state of service `load-balancer-service`

   ```console
   debian@busybox:~$ kubectl get service load-balancer-service -o wide
   ```

   The response should look similar to this:

   ```text
   NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE   SELECTOR
   load-balancer-service   LoadBalancer   10.107.119.217   <pending>     80:30154/TCP   9s    app=guestbook,tier=frontend
   ```

> If you look at the status on the `EXTERNAL-IP` it is **`<pending>`** because we need configure MetalLB to provide IP to `LoadBalancer` service.

### Deploy

To install MetalLB, apply the manifest:

1. Apply the MetalLB manifest `namespace` from the `namespace.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/namespace.yaml
   ```

      The response should look similar to this:

   ```text
   namespace/metallb-system created
   ```

2. Apply the MetalLB manifest `controller` and `speaker` from the `metallb.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.9.3/manifests/metallb.yaml
   ```

   The response should look similar to this:

   ```text
   podsecuritypolicy.policy/controller created
   podsecuritypolicy.policy/speaker created
   serviceaccount/controller created
   serviceaccount/speaker created
   clusterrole.rbac.authorization.k8s.io/metallb-system:controller created
   clusterrole.rbac.authorization.k8s.io/metallb-system:speaker created
   role.rbac.authorization.k8s.io/config-watcher created
   role.rbac.authorization.k8s.io/pod-lister created
   clusterrolebinding.rbac.authorization.k8s.io/metallb-system:controller created
   clusterrolebinding.rbac.authorization.k8s.io/metallb-system:speaker created
   rolebinding.rbac.authorization.k8s.io/config-watcher created
   rolebinding.rbac.authorization.k8s.io/pod-lister created
   daemonset.apps/speaker created
   deployment.apps/controller created
   ```

3. Create the MetalLB scret `memberlist`:

   ```console
   debian@busybox:~$ kubectl create secret generic -n metallb-system memberlist --from-literal=secretkey="$(openssl rand -base64 128)"
   ```

   The response should look similar to this:

   ```text
   secret/memberlist created
   ```

4. Query the state of deploy

   ```shell
   debian@busybox:~$ kubectl get deploy -n metallb-system -o wide
   ```

   The response should look similar to this:

   ```text
   NAME         READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                      SELECTOR
   controller   1/1     1            1           28s   controller   metallb/controller:v0.9.3   app=metallb,component=controller
   ```

This will deploy MetalLB to your cluster, under the **`metallb-system`** namespace. The components in the manifest are:

* The **`metallb-system/controller`** deployment. This is the cluster-wide controller that handles IP address assignments.  
* The **`metallb-system/speaker`** daemonset. This is the component that speaks the protocol(s) of your choice to make the services reachable.  
* Service accounts for the controller and speaker, along with the RBAC permissions that the components need to function. 

The installation manifest does not include a configuration file. MetalLB’s components will still start, but will remain idle until you define and deploy a `configmap`. The `memberlist` secret contains the `secretkey` to encrypt the communication between speakers for the fast dead node detection.

> Reference : https://metallb.universe.tf/installation/#installation-by-manifest

### Configure

Based on the planed network configuration ([here](/documentation/network-segmentation.md#loadbalancer)) we will have a [`metallb-config.yaml`](../metallb/metallb-config.yaml) as below:

```yaml
apiVersion: v1
kind: ConfigMap
metadata:
  namespace: metallb-system
  name: config
data:
  config: |
    address-pools:
    - name: default
      protocol: layer2
      addresses:
      - 192.168.2.2-192.168.2.125
```

1. Apply the MetalLB configmap from the `metallb-config.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://raw.githubusercontent.com/mvallim/kubernetes-under-the-hood/master/metallb/metallb-config.yaml
   ```

2. Query the state of deploy

   ```console
   debian@busybox:~$ kubectl get deploy controller -n metallb-system -o wide
   ```

   The response should look similar to this:

   ```text
   NAME         READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                      SELECTOR
   controller   1/1     1            1           5m34s   controller   metallb/controller:v0.8.3   app=metallb,component=controller
   ```

3. Query the state of service `load-balancer-service`

   ```console
   debian@busybox:~$ kubectl get service load-balancer-service -o wide
   ```

   The response should look similar to this:

   ```text
   NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)        AGE    SELECTOR
   load-balancer-service   LoadBalancer   10.107.119.217   192.168.2.10   80:30154/TCP   3m4s   app=guestbook,tier=frontend
   ```

> Now if you look at the status on the `EXTERNAL-IP` it is **`192.168.2.10`** and can be access directly from external, without using [`NodePort`](/documentation/kube.md#service) or [`ClusterIp`](/documentation/kube.md#service). Remember this IP **`192.168.2.10`** isn't assigned to any node. In this example of service we can access using [`http://192.168.2.10`](http://192.168.2.10).

### Cleaning up

Deleting the services

1. Run the following commands to delete service.

   ```console
   debian@busybox:~$ kubectl delete service load-balancer-service
   ```

   The responses should be:

   ```text
   service "load-balancer-service" deleted
   ```

2. Query the list of service:

   ```console
   debian@busybox:~$ kubectl get services
   ```

   The response should be this:

   ```text
   NAME         TYPE        CLUSTER-IP   EXTERNAL-IP   PORT(S)   AGE
   kubernetes   ClusterIP   10.96.0.1    <none>        443/TCP   2d2h
   ```
