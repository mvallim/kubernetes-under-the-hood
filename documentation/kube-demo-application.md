## Demo Application

> Full referenced: https://kubernetes.io/docs/tutorials/stateless-application/guestbook/

### Start up the Redis Master
The guestbook application uses Redis to store its data. It writes its data to a Redis master instance and reads data from multiple Redis slave instances.

1. Launch a terminal window in the directory you downloaded the manifest files.

2. Apply the Redis Master Deployment from the `redis-master-deployment.yaml` file:
   ```
   kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-deployment.yaml
   ```
3. Query the list of Pods to verify that the Redis Master Pod is running:
   ```
   kubectl get pods
   ```

   The response should be similar to this:
   ```
   NAME                            READY     STATUS    RESTARTS   AGE
   redis-master-1068406935-3lswp   1/1       Running   0          28s
   ```

4. Run the following command to view the logs from the Redis Master Pod:
   ```
   kubectl logs -f POD-NAME
   ```

> Note: Replace POD-NAME with the name of your Pod.

### Creating the Redis Master Service
The guestbook applications needs to communicate to the Redis master to write its data. You need to apply a Service to proxy the traffic to the Redis master Pod. A Service defines a policy to access the Pods.

1. Apply the Redis Master Service from the following `redis-master-service.yaml` file:
   ```
   kubectl apply -f https://k8s.io/examples/application/guestbook/redis-master-service.yaml
   ```

2. Query the list of Services to verify that the Redis Master Service is running:
   ```
   kubectl get service
   ```
   
   The response should be similar to this:
   ```
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
   ```
   kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-deployment.yaml
   ```
2. Query the list of Pods to verify that the Redis Slave Pods are running:
   ```
   kubectl get pods
   ```

   The response should be similar to this:
   ```
   NAME                            READY   STATUS              RESTARTS   AGE
   redis-master-6fbbc44567-sxvjh   1/1     Running             0          66s
   redis-slave-74ccb764fc-smr7n    0/1     ContainerCreating   0          6s
   redis-slave-74ccb764fc-sps4r    0/1     ContainerCreating   0          6s
   ```

#### Creating the Redis Slave Service
The guestbook application needs to communicate to Redis slaves to read data. To make the Redis slaves discoverable, you need to set up a Service. A Service provides transparent load balancing to a set of Pods.

1. Apply the Redis Slave Service from the following `redis-slave-service.yaml` file:
   ```
   kubectl apply -f https://k8s.io/examples/application/guestbook/redis-slave-service.yaml
   ```

2. Query the list of Services to verify that the Redis slave service is running:
   ```
   kubectl get services
   ```
   
   The response should be similar to this:
   ```
   NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)    AGE
   kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP    46h
   redis-master   ClusterIP   10.103.95.1      <none>        6379/TCP   2m15s
   redis-slave    ClusterIP   10.105.138.125   <none>        6379/TCP   7s
   ```

### Set up and Expose the Guestbook Frontend
The guestbook application has a web frontend serving the HTTP requests written in PHP. It is configured to connect to the `redis-master` Service for write requests and the `redis-slave` service for Read requests.

#### Creating the Guestbook Frontend Deployment
1. Apply the frontend Deployment from the `frontend-deployment.yaml` file:
   ```
   kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-deployment.yaml
   ```

2. Query the list of Pods to verify that the three frontend replicas are running:
   ```
   kubectl get pods -l app=guestbook -l tier=frontend
   ```
   
   The response should be similar to this:
   ```
   NAME                            READY   STATUS    RESTARTS   AGE
   frontend-74b4665db5-vr6hf       1/1     Running   0          70s
   frontend-74b4665db5-z76vh       1/1     Running   0          70s
   frontend-74b4665db5-zg5kw       1/1     Running   0          70s
   ```

#### Creating the Frontend Service
The `redis-slave` and `redis-master` Services you applied are only accessible within the container cluster because the default type for a Service is ClusterIP. `ClusterIP` provides a single IP address for the set of Pods the Service is pointing to. This IP address is accessible only within the cluster.

1. Apply the frontend Service from the `frontend-service.yaml` file:
   ```
   kubectl apply -f https://k8s.io/examples/application/guestbook/frontend-service.yaml
   ```

2. Query the list of Services to verify that the frontend Service is running:
   ```
   kubectl get services 
   ```
   
   The response should be similar to this:
   ```
   NAME           TYPE        CLUSTER-IP       EXTERNAL-IP   PORT(S)        AGE
   frontend       NodePort    10.99.225.158    <none>        80:30551/TCP   9s
   kubernetes     ClusterIP   10.96.0.1        <none>        443/TCP        46h
   redis-master   ClusterIP   10.103.95.1      <none>        6379/TCP       4m17s
   redis-slave    ClusterIP   10.105.138.125   <none>        6379/TCP       2m9s
   ```

#### Viewing the Frontend Service via **`NodePort`**
Open your browser with address [http://kube-node01.kube.local:30551](http://kube-node01.kube.local:30551)

> Keep attention on port **`30551`**, you should change correspondent port show in your on output above.

### Scale the Web Frontend
Scaling up or down is easy because your servers are defined as a Service that uses a Deployment controller.

1. Run the following command to scale up the number of frontend Pods:
   ```
   kubectl scale deployment frontend --replicas=5
   ```
   
2. Query the list of Pods to verify the number of frontend Pods running:
   ```
   kubectl get pods
   ```
   
   The response should look similar to this:
   ```
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
   ```
   kubectl scale deployment frontend --replicas=2
   ```

4. Query the list of Pods to verify the number of frontend Pods running:
   ```
   kubectl get pods
   ```

   The response should look similar to this:
   ```
   NAME                            READY   STATUS    RESTARTS   AGE
   frontend-74b4665db5-z76vh       1/1     Running   0          6m18s
   frontend-74b4665db5-zg5kw       1/1     Running   0          6m18s
   redis-master-6fbbc44567-sxvjh   1/1     Running   0          9m39s
   redis-slave-74ccb764fc-smr7n    1/1     Running   0          8m39s
   redis-slave-74ccb764fc-sps4r    1/1     Running   0          8m39s
   ```

### Cleaning up
Deleting the Deployments and Services also deletes any running Pods. Use labels to delete multiple resources with one command.

1. Run the following commands to delete all Pods, Deployments, and Services.
   ```
   kubectl delete deployment -l app=redis
   kubectl delete service -l app=redis
   kubectl delete deployment -l app=guestbook
   kubectl delete service -l app=guestbook
   ```

   The responses should be:
   ```
   deployment.apps "redis-master" deleted
   deployment.apps "redis-slave" deleted
   service "redis-master" deleted
   service "redis-slave" deleted
   deployment.apps "frontend" deleted    
   service "frontend" deleted
   ```

2. Query the list of Pods to verify that no Pods are running:
   ```
   kubectl get pods
   ```

   The response should be this:
   ```
   No resources found.
   ```