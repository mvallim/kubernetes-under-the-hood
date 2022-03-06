# Demo Application

> Full referenced: https://kubernetes.io/docs/tutorials/stateless-application/guestbook/

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

## Start up the Redis Leader

The guestbook application uses Redis to store its data. It writes its data to a Redis leader instance and reads data from multiple Redis followers instances.

1. Apply the Redis Leader Deployment from the `redis-leader-deployment.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-leader-deployment.yaml
   ```

2. Query the list of Pods to verify that the Redis Leader Pod is running:

   ```console
   debian@busybox:~$ kubectl get pods
   ```

   The response should be similar to this:

   ```text
   NAME                           READY   STATUS    RESTARTS   AGE
   redis-leader-fb76b4755-g7s42   1/1     Running   0          11s
   ```

3. Run the following command to view the logs from the Redis Leader Pod:

   ```text
   kubectl logs -f POD-NAME
   ```

> Note: Replace POD-NAME with the name of your Pod.

## Creating the Redis Leader Service

The guestbook applications needs to communicate to the Redis leader to write its data. You need to apply a Service to proxy the traffic to the Redis leader Pod. A Service defines a policy to access the Pods.

1. Apply the Redis Leader Service from the following `redis-leader-service.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-leader-service.yaml
   ```

2. Query the list of Services to verify that the Redis Leader Service is running:

   ```console
   debian@busybox:~$ kubectl get service
   ```

   The response should be similar to this:

   ```text
   NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
   kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP    2d22h
   redis-leader   ClusterIP   10.101.140.177   <none>        6379/TCP   5s
   ```

> Note: This manifest file creates a Service named `redis-leader` with a set of labels that match the labels previously defined, so the Service routes network traffic to the Redis leader Pod.

## Start up the Redis Followers

Although the Redis leader is a single pod, you can make it highly available to meet traffic demands by adding replica Redis followers.

### Creating the Redis Follower Deployment

Deployments scale based off of the configurations set in the manifest file. In this case, the Deployment object specifies two replicas.

If there are not any replicas running, this Deployment would start the two replicas on your container cluster. Conversely, if there are more than two replicas are running, it would scale down until two replicas are running.

1. Apply the Redis Follower Deployment from the `redis-follower-deployment.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-follower-deployment.yaml
   ```

2. Query the list of Pods to verify that the Redis Follower Pods are running:

   ```console
   debian@busybox:~$ kubectl get pods
   ```

   The response should be similar to this:

   ```text
   NAME                             READY   STATUS    RESTARTS   AGE
   redis-follower-dddfbdcc9-4pcrs   1/1     Running   0          18s
   redis-follower-dddfbdcc9-jfs29   1/1     Running   0          18s
   redis-leader-fb76b4755-g7s42     1/1     Running   0          4m36s
   ```

### Creating the Redis Replica Service

The guestbook application needs to communicate to Redis followers to read data. To make the Redis followers discoverable, you need to set up a Service. A Service provides transparent load balancing to a set of Pods.

1. Apply the Redis Follower Service from the following `redis-follower-service.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-follower-service.yaml
   ```

2. Query the list of Services to verify that the Redis follower service is running:

   ```console
   debian@busybox:~$ kubectl get services
   ```

   The response should be similar to this:

   ```text
   NAME             TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
   kubernetes       ClusterIP   10.96.0.1        <none>        443/TCP    2d22h
   redis-follower   ClusterIP   10.98.90.120     <none>        6379/TCP   8s
   redis-leader     ClusterIP   10.101.140.177   <none>        6379/TCP   4m24s
   ```

## Set up and Expose the Guestbook Frontend

The guestbook application has a web frontend serving the HTTP requests written in PHP. It is configured to connect to the `redis-leader` Service for write requests and the `redis-follower` service for Read requests.

### Creating the Guestbook Frontend Deployment

1. Apply the frontend Deployment from the `frontend-deployment.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml
   ```

2. Query the list of Pods to verify that the three frontend replicas are running:

   ```console
   debian@busybox:~$ kubectl get pods -l app=guestbook -l tier=frontend
   ```

   The response should be similar to this:

   ```text
   NAME                        READY   STATUS    RESTARTS   AGE
   frontend-85595f5bf9-cdlkc   1/1     Running   0          71s
   frontend-85595f5bf9-d7p9m   1/1     Running   0          71s
   frontend-85595f5bf9-mpvhz   1/1     Running   0          71s
   ```

### Creating the Frontend Service

The `redis-follower` and `redis-leader` Services you applied are only accessible within the container cluster because the default type for a Service is ClusterIP. `ClusterIP` provides a single IP address for the set of Pods the Service is pointing to. This IP address is accessible only within the cluster.

1. Apply the frontend Service from the `frontend-service.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://raw.githubusercontent.com/mvallim/kubernetes-under-the-hood/master/services/kube-service-nodeport.yaml
   ```

2. Query the list of Services to verify that the frontend Service is running:

   ```console
   debian@busybox:~$ kubectl get services
   ```

   The response should be similar to this:

   ```text
   NAME               TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
   kubernetes         ClusterIP   10.96.0.1        <none>        443/TCP        2d22h
   nodeport-service   NodePort    10.105.255.221   <none>        80:32767/TCP   12s
   redis-follower     ClusterIP   10.98.90.120     <none>        6379/TCP       11m
   redis-leader       ClusterIP   10.101.140.177   <none>        6379/TCP       15m
   ```

### Viewing the Frontend Service via **`NodePort`**

1. Query the nodes and ip information

   ```console
   debian@busybox:~$ kubectl get nodes -o wide
   ```

   The response should look similar to this:

   ```console
   NAME          STATUS   ROLES                  AGE     VERSION    INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION    CONTAINER-RUNTIME
   kube-mast01   Ready    control-plane,master   2d22h   v1.20.15   192.168.1.18    <none>        Debian GNU/Linux 10 (buster)   4.19.0-18-amd64   containerd://1.4.12
   kube-mast02   Ready    control-plane,master   2d22h   v1.20.15   192.168.1.27    <none>        Debian GNU/Linux 10 (buster)   4.19.0-18-amd64   containerd://1.4.12
   kube-mast03   Ready    control-plane,master   2d22h   v1.20.15   192.168.1.37    <none>        Debian GNU/Linux 10 (buster)   4.19.0-18-amd64   containerd://1.4.12
   kube-node01   Ready    <none>                 2d22h   v1.20.15   192.168.2.185   <none>        Debian GNU/Linux 10 (buster)   4.19.0-18-amd64   containerd://1.4.12
   kube-node02   Ready    <none>                 2d22h   v1.20.15   192.168.2.159   <none>        Debian GNU/Linux 10 (buster)   4.19.0-18-amd64   containerd://1.4.12
   kube-node03   Ready    <none>                 2d22h   v1.20.15   192.168.2.171   <none>        Debian GNU/Linux 10 (buster)   4.19.0-18-amd64   containerd://1.4.12
   ```

2. Choice any ip of `kube-nodes` (`kube-node01`, `kube-node02` or `kube-node03`)

   Here we will use the `192.168.2.185` (`kube-node01`)

   Open your browser with address [http://192.168.2.185:32767](http://192.168.2.185:32767)

> Keep attention on port **`32767`**, you should change correspondent port show in your on output above.

## Scale the Web Frontend

Scaling up or down is easy because your servers are defined as a Service that uses a Deployment controller.

1. Run the following command to scale up the number of frontend Pods:

   ```console
   debian@busybox:~$ kubectl scale deployment frontend --replicas=5
   ```

2. Query the list of Pods to verify the number of frontend Pods running:

   ```console
   debian@busybox:~$ kubectl get pods
   ```

   The response should look similar to this:

   ```text
   NAME                             READY   STATUS    RESTARTS   AGE
   frontend-85595f5bf9-cdlkc        1/1     Running   0          12m
   frontend-85595f5bf9-d7p9m        1/1     Running   0          12m
   frontend-85595f5bf9-lvpfh        1/1     Running   0          6s
   frontend-85595f5bf9-mpvhz        1/1     Running   0          12m
   frontend-85595f5bf9-srn4q        1/1     Running   0          6s
   redis-follower-dddfbdcc9-4pcrs   1/1     Running   0          15m
   redis-follower-dddfbdcc9-jfs29   1/1     Running   0          15m
   redis-leader-fb76b4755-g7s42     1/1     Running   0          20m
   ```

3. Run the following command to scale down the number of frontend Pods:

   ```console
   debian@busybox:~$ kubectl scale deployment frontend --replicas=2
   ```

4. Query the list of Pods to verify the number of frontend Pods running:

   ```console
   debian@busybox:~$ kubectl get pods
   ```

   The response should look similar to this:

   ```text
   NAME                             READY   STATUS    RESTARTS   AGE
   frontend-85595f5bf9-cdlkc        1/1     Running   0          13m
   frontend-85595f5bf9-d7p9m        1/1     Running   0          13m
   redis-follower-dddfbdcc9-4pcrs   1/1     Running   0          16m
   redis-follower-dddfbdcc9-jfs29   1/1     Running   0          16m
   redis-leader-fb76b4755-g7s42     1/1     Running   0          20m
   ```

## Cleaning up (Don't clean if you enable [`LoadBalancer`](/documentation/kube-metallb.md))

Deleting the Deployments and Services also deletes any running Pods. Use labels to delete multiple resources with one command.

1. Run the following commands to delete all Pods, Deployments, and Services.

   ```console
   debian@busybox:~$ kubectl delete -n default deployment frontend

   debian@busybox:~$ kubectl delete -n default deployment redis-follower

   debian@busybox:~$ kubectl delete -n default deployment redis-leader

   debian@busybox:~$ kubectl delete -n default service -l app=redis

   debian@busybox:~$ kubectl delete -n default service -l app=guestbook
   ```

   The responses should be:

   ```text
   deployment.apps "redis-master" deleted
   deployment.apps "redis-slave" deleted
   service "redis-master" deleted
   service "redis-slave" deleted
   deployment.apps "frontend" deleted
   service "frontend" deleted
   ```

2. Query the list of Pods to verify that no Pods are running:

   ```console
   debian@busybox:~$ kubectl get pods
   ```

   The response should be this:

   ```text
   No resources found in default namespace.
   ```
