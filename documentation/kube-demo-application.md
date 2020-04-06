## Demo Application

> Full referenced: https://kubernetes.io/docs/tutorials/stateless-application/guestbook/

### Configure your local routing

You need to add a route to your local machine to access the internal network of **Virtualbox**.

```console
~$ sudo ip route add 192.168.4.0/27 via 192.168.4.30 dev vboxnet0
~$ sudo ip route add 192.168.4.32/27 via 192.168.4.62 dev vboxnet0
~$ sudo ip route add 192.168.2.0/24 via 192.168.4.254 dev vboxnet0
```

### Access the BusyBox

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

### Start up the Redis Master

The guestbook application uses Redis to store its data. It writes its data to a Redis master instance and reads data from multiple Redis slave instances.

1. Apply the Redis Master Deployment from the `redis-master-deployment.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-deployment.yaml
   ```

2. Query the list of Pods to verify that the Redis Master Pod is running:

   ```console
   debian@busybox:~$ kubectl get pods
   ```

   The response should be similar to this:

   ```text
   NAME                            READY     STATUS    RESTARTS   AGE
   redis-master-1068406935-3lswp   1/1       Running   0          28s
   ```

3. Run the following command to view the logs from the Redis Master Pod:

   ```text
   kubectl logs -f POD-NAME
   ```

> Note: Replace POD-NAME with the name of your Pod.

### Creating the Redis Master Service

The guestbook applications needs to communicate to the Redis master to write its data. You need to apply a Service to proxy the traffic to the Redis master Pod. A Service defines a policy to access the Pods.

1. Apply the Redis Master Service from the following `redis-master-service.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-service.yaml
   ```

2. Query the list of Services to verify that the Redis Master Service is running:

   ```console
   debian@busybox:~$ kubectl get service
   ```

   The response should be similar to this:

   ```text
   NAME           TYPE        CLUSTER-IP    EXTERNAL-IP   PORT(S)    AGE
   kubernetes     ClusterIP   10.96.0.1     <none>        443/TCP    46h
   redis-master   ClusterIP   10.103.95.1   <none>        6379/TCP   7s
   ```

> Note: This manifest file creates a Service named `redis-master` with a set of labels that match the labels previously defined, so the Service routes network traffic to the Redis master Pod.

### Start up the Redis Slaves

Although the Redis master is a single pod, you can make it highly available to meet traffic demands by adding replica Redis slaves.

#### Creating the Redis Slave Deployment

Deployments scale based off of the configurations set in the manifest file. In this case, the Deployment object specifies two replicas.

If there are not any replicas running, this Deployment would start the two replicas on your container cluster. Conversely, if there are more than two replicas are running, it would scale down until two replicas are running.

1. Apply the Redis Slave Deployment from the `redis-slave-deployment.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-deployment.yaml
   ```

2. Query the list of Pods to verify that the Redis Slave Pods are running:

   ```console
   debian@busybox:~$ kubectl get pods
   ```

   The response should be similar to this:

   ```text
   NAME                            READY   STATUS              RESTARTS   AGE
   redis-master-6fbbc44567-sxvjh   1/1     Running             0          66s
   redis-slave-74ccb764fc-smr7n    0/1     ContainerCreating   0          6s
   redis-slave-74ccb764fc-sps4r    0/1     ContainerCreating   0          6s
   ```

#### Creating the Redis Slave Service

The guestbook application needs to communicate to Redis slaves to read data. To make the Redis slaves discoverable, you need to set up a Service. A Service provides transparent load balancing to a set of Pods.

1. Apply the Redis Slave Service from the following `redis-slave-service.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-service.yaml
   ```

2. Query the list of Services to verify that the Redis slave service is running:

   ```console
   debian@busybox:~$ kubectl get services
   ```

   The response should be similar to this:

   ```text
   NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
   kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP    46h
   redis-master   ClusterIP   10.103.95.1      <none>        6379/TCP   2m15s
   redis-slave    ClusterIP   10.105.138.125   <none>        6379/TCP   7s
   ```

### Set up and Expose the Guestbook Frontend

The guestbook application has a web frontend serving the HTTP requests written in PHP. It is configured to connect to the `redis-master` Service for write requests and the `redis-slave` service for Read requests.

#### Creating the Guestbook Frontend Deployment

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
   NAME                            READY   STATUS    RESTARTS   AGE
   frontend-74b4665db5-vr6hf       1/1     Running   0          70s
   frontend-74b4665db5-z76vh       1/1     Running   0          70s
   frontend-74b4665db5-zg5kw       1/1     Running   0          70s
   ```

#### Creating the Frontend Service

The `redis-slave` and `redis-master` Services you applied are only accessible within the container cluster because the default type for a Service is ClusterIP. `ClusterIP` provides a single IP address for the set of Pods the Service is pointing to. This IP address is accessible only within the cluster.

1. Apply the frontend Service from the `frontend-service.yaml` file:

   ```console
   debian@busybox:~$ kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml
   ```

2. Query the list of Services to verify that the frontend Service is running:

   ```console
   debian@busybox:~$ kubectl get services
   ```

   The response should be similar to this:

   ```text
   NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
   frontend       NodePort    10.99.225.158    <none>        80:30551/TCP   9s
   kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP        46h
   redis-master   ClusterIP   10.103.95.1      <none>        6379/TCP       4m17s
   redis-slave    ClusterIP   10.105.138.125   <none>        6379/TCP       2m9s
   ```

#### Viewing the Frontend Service via **`NodePort`**

1. Query the nodes and ip information

   ```console
   debian@busybox:~$ kubectl get nodes -o wide
   ```

   The response should look similar to this:

   ```text
   NAME          STATUS   ROLES    AGE   VERSION   INTERNAL-IP     EXTERNAL-IP   OS-IMAGE                       KERNEL-VERSION   CONTAINER-RUNTIME
   kube-mast01   Ready    master   73m   v1.15.6   192.168.1.64    <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-mast02   Ready    master   69m   v1.15.6   192.168.1.69    <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-mast03   Ready    master   65m   v1.15.6   192.168.1.170   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-node01   Ready    <none>   51m   v1.15.6   192.168.2.136   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-node02   Ready    <none>   50m   v1.15.6   192.168.2.205   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   kube-node03   Ready    <none>   50m   v1.15.6   192.168.2.195   <none>        Debian GNU/Linux 9 (stretch)   4.9.0-11-amd64   docker://18.6.0
   ```

Open your browser with address [http://kube-node01.kube.demo:30551](http://kube-node01.kube.demo:30551)

> Keep attention on port **`30551`**, you should change correspondent port show in your on output above.

### Scale the Web Frontend

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
   NAME                            READY   STATUS    RESTARTS   AGE
   frontend-74b4665db5-n2bsk       1/1     Running   0          8s
   frontend-74b4665db5-sf42s       1/1     Running   0          8s
   frontend-74b4665db5-vr6hf       1/1     Running   0          5m24s
   frontend-74b4665db5-z76vh       1/1     Running   0          5m24s
   frontend-74b4665db5-zg5kw       1/1     Running   0          5m24s
   redis-master-6fbbc44567-sxvjh   1/1     Running   0          8m45s
   redis-slave-74ccb764fc-smr7n    1/1     Running   0          7m45s
   redis-slave-74ccb764fc-sps4r    1/1     Running   0          7m45s
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
   NAME                            READY   STATUS    RESTARTS   AGE
   frontend-74b4665db5-z76vh       1/1     Running   0          6m18s
   frontend-74b4665db5-zg5kw       1/1     Running   0          6m18s
   redis-master-6fbbc44567-sxvjh   1/1     Running   0          9m39s
   redis-slave-74ccb764fc-smr7n    1/1     Running   0          8m39s
   redis-slave-74ccb764fc-sps4r    1/1     Running   0          8m39s
   ```

### Cleaning up (Don't clean if you enable [`LoadBalancer`](/documentation/kube-metallb.md))

Deleting the Deployments and Services also deletes any running Pods. Use labels to delete multiple resources with one command.

1. Run the following commands to delete all Pods, Deployments, and Services.

   ```console
   debian@busybox:~$ kubectl delete deployment -l app=redis
   kubectl delete service -l app=redis
   kubectl delete deployment -l app=guestbook
   kubectl delete service -l app=guestbook
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
   No resources found.
   ```
