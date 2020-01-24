# Kubernetes Dashboard

Dashboard is a web-based Kubernetes user interface. You can use Dashboard to deploy containerized applications to a Kubernetes cluster, troubleshoot your containerized application, and manage the cluster resources. You can use Dashboard to get an overview of applications running on your cluster, as well as for creating or modifying individual Kubernetes resources (such as Deployments, Jobs, DaemonSets, etc). For example, you can scale a Deployment, initiate a rolling update, restart a pod or deploy new applications using a deploy wizard.

Dashboard also provides information on the state of Kubernetes resources in your cluster and on any errors that may have occurred.

<p align="center">
  <img src="images/kube-dashboard.png">
</p>

## Deploy

1. Create the dashboard from the `kubernetes-dashboard.yaml` file:

   ```shell
   ssh debian@kube-mast01.kube.demo

   sudo su -

   kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
   ```

   The response should look similar to this:

   ```text
   secret/kubernetes-dashboard-certs created
   secret/kubernetes-dashboard-csrf created
   serviceaccount/kubernetes-dashboard created
   role.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
   rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard-minimal created
   deployment.apps/kubernetes-dashboard created
   service/kubernetes-dashboard created
   ```

2. Checking the state of pods after dashboard deployed

   ```shell
   kubectl get pods -o wide -n kube-system
   ```

   The response should look similar to this:

   ```text
   NAME                                   READY   STATUS    RESTARTS   AGE    IP              NODE          NOMINATED NODE   READINESS GATES
   coredns-86c58d9df4-6gzrk               1/1     Running   0          171m   10.244.0.4      kube-mast01   <none>           <none>
   coredns-86c58d9df4-fxj5r               1/1     Running   0          171m   10.244.0.5      kube-mast01   <none>           <none>
   etcd-kube-mast01                       1/1     Running   0          170m   192.168.1.72    kube-mast01   <none>           <none>
   etcd-kube-mast02                       1/1     Running   0          141m   192.168.1.68    kube-mast02   <none>           <none>
   etcd-kube-mast03                       1/1     Running   0          140m   192.168.1.81    kube-mast03   <none>           <none>
   kube-apiserver-kube-mast01             1/1     Running   0          170m   192.168.1.72    kube-mast01   <none>           <none>
   kube-apiserver-kube-mast02             1/1     Running   1          141m   192.168.1.68    kube-mast02   <none>           <none>
   kube-apiserver-kube-mast03             1/1     Running   0          139m   192.168.1.81    kube-mast03   <none>           <none>
   kube-controller-manager-kube-mast01    1/1     Running   1          170m   192.168.1.72    kube-mast01   <none>           <none>
   kube-controller-manager-kube-mast02    1/1     Running   1          141m   192.168.1.68    kube-mast02   <none>           <none>
   kube-controller-manager-kube-mast03    1/1     Running   0          140m   192.168.1.81    kube-mast03   <none>           <none>
   kube-flannel-ds-amd64-4dmxn            1/1     Running   0          11m    192.168.2.188   kube-node02   <none>           <none>
   kube-flannel-ds-amd64-545vl            1/1     Running   0          165m   192.168.1.72    kube-mast01   <none>           <none>
   kube-flannel-ds-amd64-gnngz            1/1     Running   0          140m   192.168.1.81    kube-mast03   <none>           <none>
   kube-flannel-ds-amd64-lqfqp            1/1     Running   0          10m    192.168.2.144   kube-node03   <none>           <none>
   kube-flannel-ds-amd64-trxc2            1/1     Running   0          141m   192.168.1.68    kube-mast02   <none>           <none>
   kube-flannel-ds-amd64-zhd6c            1/1     Running   0          11m    192.168.2.185   kube-node01   <none>           <none>
   kube-proxy-2zvvb                       1/1     Running   0          11m    192.168.2.185   kube-node01   <none>           <none>
   kube-proxy-8kb86                       1/1     Running   0          171m   192.168.1.72    kube-mast01   <none>           <none>
   kube-proxy-9blvj                       1/1     Running   0          11m    192.168.2.188   kube-node02   <none>           <none>
   kube-proxy-cpspc                       1/1     Running   0          140m   192.168.1.81    kube-mast03   <none>           <none>
   kube-proxy-hmqpn                       1/1     Running   0          10m    192.168.2.144   kube-node03   <none>           <none>
   kube-proxy-j6sch                       1/1     Running   0          141m   192.168.1.68    kube-mast02   <none>           <none>
   kube-scheduler-kube-mast01             1/1     Running   1          170m   192.168.1.72    kube-mast01   <none>           <none>
   kube-scheduler-kube-mast02             1/1     Running   0          141m   192.168.1.68    kube-mast02   <none>           <none>
   kube-scheduler-kube-mast03             1/1     Running   0          140m   192.168.1.81    kube-mast03   <none>           <none>
   kubernetes-dashboard-57df4db6b-pcwn2   1/1     Running   0          75s    10.244.3.2      kube-node01   <none>           <none>
   ```

   > Now you can see the dashboard pod `kubernetes-dashboard-57df4db6b-pcwn2`

## Configure

### `serviceaccount`

We need service account to access K8S Dashboard

1. Create service account

   ```shell
   kubectl create serviceaccount cluster-admin-dashboard -n kubernetes-dashboard

   kubectl create clusterrolebinding cluster-admin-dashboard \
       --clusterrole=cluster-admin \
       --serviceaccount=kubernetes-dashboard:cluster-admin-dashboard \
       -n kubernetes-dashboard
   ```

   The responses should look similar to this:

   ```text
   serviceaccount/cluster-admin-dashboard created
   ```

   ```text
   clusterrolebinding.rbac.authorization.k8s.io/cluster-admin-dashboard created
   ```

### View Dashboard

#### Bearer Token

We need get token of service account `cluster-admin-dashboard`

1. Query secrets

   ```shell
   kubectl get secret -n kubernetes-dashboard
   ```

   The response should look similar to this:

   ```text
   NAME                                  TYPE                                  DATA   AGE
   cluster-admin-dashboard-token-zth9n   kubernetes.io/service-account-token   3      66s
   default-token-9lnss                   kubernetes.io/service-account-token   3      86m
   kubernetes-dashboard-certs            Opaque                                0      86m
   kubernetes-dashboard-csrf             Opaque                                1      86m
   kubernetes-dashboard-key-holder       Opaque                                2      86m
   kubernetes-dashboard-token-k48sq      kubernetes.io/service-account-token   3      86m
   ```

   > Now you can see the service account token of `cluster-admin-dashboard` with name `cluster-admin-dashboard-token-zth9n`

2. Get token we describe `cluster-admin-dashboard-token-zth9n`

   ```shell
   kubectl describe secret cluster-admin-dashboard-token-zth9n -n kubernetes-dashboard
   ```

   The response should look similar to this:

   ```text
   Name:         cluster-admin-dashboard-token-zth9n
   Namespace:    kubernetes-dashboard
   Labels:       <none>
   Annotations:  kubernetes.io/service-account.name: cluster-admin-dashboard
                 kubernetes.io/service-account.uid: b724e475-775e-4c43-9395-d95603b02221

   Type:  kubernetes.io/service-account-token

   Data
   ====
   ca.crt:     1025 bytes
   namespace:  20 bytes
   token:      eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9.eyJpc3MiOiJrdWJlcm5ldGVzL3NlcnZpY2VhY2NvdW50Iiwia3ViZXJuZXRlcy5pby9zZXJ2aWNlYWNjb3VudC9uYW1lc3BhY2UiOiJrdWJlcm5ldGVzLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VjcmV0Lm5hbWUiOiJjbHVzdGVyLWFkbWluLWRhc2hib2FyZC10b2tlbi16dGg5biIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50Lm5hbWUiOiJjbHVzdGVyLWFkbWluLWRhc2hib2FyZCIsImt1YmVybmV0ZXMuaW8vc2VydmljZWFjY291bnQvc2VydmljZS1hY2NvdW50LnVpZCI6ImI3MjRlNDc1LTc3NWUtNGM0My05Mzk1LWQ5NTYwM2IwMjIyMSIsInN1YiI6InN5c3RlbTpzZXJ2aWNlYWNjb3VudDprdWJlcm5ldGVzLWRhc2hib2FyZDpjbHVzdGVyLWFkbWluLWRhc2hib2FyZCJ9.cJrZQCZPXVwg5xV871EbnTiuxB0KtIyZZyDanthEXyJl9Wcj8xs11GCiKPQAodwDZtF693WCP0-xGn8M16vBQI9mEbevtkpTbj021p5OahxJnxhfdkQFW1gLIM4OwBkBn5tHMhs9D54_G4XrtHR5dt3VEL36NoKZiT3iaZovDGyg03_VpB3VviuUrQJnt0RJx4ZkoN-109EozIaV_55bromtKR-cR0d8iuctHlT8v4SgGp9CyDyYL4Ko3Y_RO4HTf2VAj-d6htv0LPToabo1-jSuC0DXjX8f-mmgIWNI0tq_jbVX96D48HMghJKF0p31pBH-0u802ePmFI3W38ZEZA
   ```

   > We are going to use token `eyJhbGciOiJSUzI1NiIsImtpZCI6IiJ9....SHgDFTnhEPP5EVSbxBx75bOzbGIatNuSGNRg-UFHcQ` (I show here first and last blocks, but you must use the full printed value)

### `kube proxy`

Now we need configure kubectl in busybox.

1. Copy config from master node

   ```shell
   mkdir ~/.kube

   ssh debian@kube-mast01 'sudo cat /etc/kubernetes/admin.conf' > ~/.kube/config
   ```

2. Start `kubectl proxy`

   ```shell
   kubectl proxy --address=0.0.0.0 --accept-hosts=^*
   ```

3. To view dashboard ui open your browser with address [http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](http://localhost:8001/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

4. Now copy the token and paste it into Enter token field on log in screen.
   ![](images/kube-dashboard-auth.png)

5. Click Sign in button and that's it. You are now logged in as an admin.
   ![](images/kube-dashboard-singin.png)
