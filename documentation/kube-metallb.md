## MetalLB
*“MetalLB is a load-balancer implementation for bare metal Kubernetes clusters, using standard routing protocols.”*
> Reference: https://metallb.universe.tf/

### Why?
*Kubernetes does not offer an implementation of network load-balancers (Services of type LoadBalancer) for bare metal clusters. The implementations of Network LB that Kubernetes does ship with are all glue code that calls out to various IaaS platforms (GCP, AWS, Azure…). If you’re not running on a supported IaaS platform (GCP, AWS, Azure…), Load Balancers will remain in the “pending” state indefinitely when created.*

### Install

#### `kube-service-load-balancer`

LoadBalancer manifest:

```
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
   ```
   kubectl apply -f https://raw.githubusercontent.com/mvallim/kubernetes-under-the-hood/master/services/kube-service-load-balancer.yaml
   ```

2. Query the state of service `load-balancer-service`
   ```
   kubectl get service load-balancer-service -o wide
   ```

   The response should look similar to this:
   ```
   NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE   SELECTOR
   load-balancer-service   LoadBalancer   10.107.119.217   <pending>     80:30154/TCP   9s    app=guestbook,tier=frontend
   ```
> If you look at the status on the `EXTERNAL-IP` it is **`<pending>`** because we need configure MetalLB to provide IP to `LoadBalancer` service.

#### Deploy

1. Apply the MetalLB deploy from the `metallb.yaml` file:
   ```
   kubectl apply -f https://raw.githubusercontent.com/google/metallb/v0.7.3/manifests/metallb.yaml
   ```

2. Query the state of deploy
   ```
   kubectl get deploy -n metallb-system -o wide
   ```

   The response should look similar to this:
   ```
   NAME         READY   UP-TO-DATE   AVAILABLE   AGE   CONTAINERS   IMAGES                      SELECTOR
   controller   0/1     1            0           7s    controller   metallb/controller:v0.7.3   app=metallb,component=controller
   ```

> If you look at the status on the `controller` it is **NotReady (0/1)** because we need configure MetalLB to provide on range of IP to `LoadBalancer` service.

#### Configure

Based on the planed network configuration ([here](/documentation/network-segmentation.md#loadbalancer)) we will have a [`metallb-config.yaml`](../metallb/metallb-config.yaml) as below:

```
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
      - 192.168.2.10-192.168.2.49
```

1. Apply the MetalLB configmap from the `metallb-config.yaml` file:
   ```
   kubectl apply -f https://raw.githubusercontent.com/mvallim/kubernetes-under-the-hood/master/metallb/metallb-config.yaml
   ```

2. Query the state of deploy
   ```
   kubectl get deploy controller -n metallb-system -o wide
   ```

   The response should look similar to this:
   ```
   NAME         READY   UP-TO-DATE   AVAILABLE   AGE     CONTAINERS   IMAGES                      SELECTOR
   controller   1/1     1            1           5m34s   controller   metallb/controller:v0.7.3   app=metallb,component=controller
   ```

3. Query the state of service `load-balancer-service`
   ```
   kubectl get deploy -n metallb-system -o wide
   ```

   The response should look similar to this:
   ```
   NAME                    TYPE           CLUSTER-IP       EXTERNAL-IP    PORT(S)        AGE    SELECTOR
   load-balancer-service   LoadBalancer   10.107.119.217   192.168.2.10   80:30154/TCP   3m4s   app=guestbook,tier=frontend
   ```

> Now if you look at the status on the `EXTERNAL-IP` it is **`192.168.2.10`** and can be access directly from external, without using [`NodePort`](/documentation/kube.md#service) or [`ClusterIp`](/documentation/kube.md#service). Remember this IP **192.168.2.10** isn't assigned to any node. In this example of service we can access using [`http://192.168.2.10`](http://192.168.2.10).
