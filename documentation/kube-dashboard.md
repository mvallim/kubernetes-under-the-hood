# Kubernetes Dashboard

Dashboard is a web-based Kubernetes user interface. You can use Dashboard to deploy containerized applications to a Kubernetes cluster, troubleshoot your containerized application, and manage the cluster resources. You can use Dashboard to get an overview of applications running on your cluster, as well as for creating or modifying individual Kubernetes resources (such as Deployments, Jobs, DaemonSets, etc). For example, you can scale a Deployment, initiate a rolling update, restart a pod or deploy new applications using a deploy wizard.

Dashboard also provides information on the state of Kubernetes resources in your cluster and on any errors that may have occurred.

<p align="center">
  <img src="images/kube-dashboard.png">
</p>

### Configure your local routing

You need to add a route to your local machine to access the internal network of **Virtualbox**.

```shell
sudo ip route add 192.168.4.0/27 via 192.168.4.30 dev vboxnet0
sudo ip route add 192.168.4.32/27 via 192.168.4.62 dev vboxnet0
```

### Access the BusyBox

We need to get the **BusyBox IP** to access it via ssh

```shell
vboxmanage guestproperty get busybox "/VirtualBox/GuestInfo/Net/0/V4/IP"
```

The responses should look similar to this:

```shell
Value: 192.168.4.57
```

Use the returned value to access.

```shell
ssh debian@192.168.4.57
```

The responses should look similar to this:

```text
Linux busybox 4.9.0-11-amd64 #1 SMP Debian 4.9.189-3+deb9u2 (2019-11-11) x86_64
The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.
Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
```

## Deploy

1. Copy config from master node

   Now we need configure kubectl in busybox.

   ```shell
   mkdir ~/.kube

   ssh kube-mast01 'sudo cat /etc/kubernetes/admin.conf' > ~/.kube/config
   ```

2. Create the dashboard from the `kubernetes-dashboard.yaml` file:

   ```shell
   kubectl apply -f https://raw.githubusercontent.com/kubernetes/dashboard/v2.0.0-beta8/aio/deploy/recommended.yaml
   ```

   The response should look similar to this:

   ```text
   namespace/kubernetes-dashboard created
   serviceaccount/kubernetes-dashboard created
   service/kubernetes-dashboard created
   secret/kubernetes-dashboard-certs created
   secret/kubernetes-dashboard-csrf created
   secret/kubernetes-dashboard-key-holder created
   configmap/kubernetes-dashboard-settings created
   role.rbac.authorization.k8s.io/kubernetes-dashboard created
   clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard created
   rolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
   clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard created
   deployment.apps/kubernetes-dashboard created
   service/dashboard-metrics-scraper created
   deployment.apps/dashboard-metrics-scraper created
   ```

3. Checking the state of pods after dashboard deployed

   ```shell
   kubectl get pods -o wide -n kubernetes-dashboard
   ```

   The response should look similar to this:

   ```text
   NAME                                         READY   STATUS    RESTARTS   AGE    IP           NODE          NOMINATED NODE   READINESS GATES
   dashboard-metrics-scraper-6c554969c6-4mmth   1/1     Running   0          2m1s   10.244.5.2   kube-node03   <none>           <none>
   kubernetes-dashboard-56c5f95c6b-ptcw6        1/1     Running   0          2m2s   10.244.3.2   kube-node01   <none>           <none>
   ```

   > Now you can see the dashboard pod `kubernetes-dashboard-56c5f95c6b-ptcw6`

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

### Access dashboard

1. Try view dashboard ui open your browser via **API Server** with address [https://192.168.4.20:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/](https://192.168.4.20:6443/api/v1/namespaces/kubernetes-dashboard/services/https:kubernetes-dashboard:/proxy/)

   Probaly you get the error to access because don't have permission

   Output like this

   ```json
   {
     "kind": "Status",
     "apiVersion": "v1",
     "metadata": {},
     "status": "Failure",
     "message": "services \"https:kubernetes-dashboard:\" is forbidden: User \"system:anonymous\" cannot get resource \"services/proxy\" in API group \"\" in the namespace \"kubernetes-dashboard\"",
     "reason": "Forbidden",
     "details": {
       "name": "https:kubernetes-dashboard:",
       "kind": "services"
     },
     "code": 403
   }
   ```

2. Create role to access resources in `kubernetes-dashboard`

   ```yaml
   kind: ClusterRole
   apiVersion: rbac.authorization.k8s.io/v1
   metadata:
     name: kubernetes-dashboard-anonymous
   rules:
   - apiGroups: [""]
     resources: ["services/proxy"]
     resourceNames: ["https:kubernetes-dashboard:"]
     verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
   - nonResourceURLs: ["/ui", "/ui/*", "/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/*"]
     verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
   ```

   ```shell
   cat <<EOF | kubectl apply -f -
   kind: ClusterRole
   apiVersion: rbac.authorization.k8s.io/v1
   metadata:
     name: kubernetes-dashboard-anonymous
   rules:
   - apiGroups: [""]
     resources: ["services/proxy"]
     resourceNames: ["https:kubernetes-dashboard:"]
     verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
   - nonResourceURLs: ["/ui", "/ui/*", "/api/v1/namespaces/kube-system/services/https:kubernetes-dashboard:/proxy/*"]
     verbs: ["get", "list", "watch", "create", "update", "patch", "delete"]
   EOF
   ```

   Output

   ```text
   clusterrole.rbac.authorization.k8s.io/kubernetes-dashboard-anonymous created
   ```

3. Create role binding to anonymous (`system:anonymous`)

   ```yaml
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: kubernetes-dashboard-anonymous
   roleRef:
     apiGroup: rbac.authorization.k8s.io
     kind: ClusterRole
     name: kubernetes-dashboard-anonymous
   subjects:
   - kind: User
     name: system:anonymous
   ```

   ```shell
   cat <<EOF | kubectl apply -f -
   apiVersion: rbac.authorization.k8s.io/v1
   kind: ClusterRoleBinding
   metadata:
     name: kubernetes-dashboard-anonymous
   roleRef:
     apiGroup: rbac.authorization.k8s.io
     kind: ClusterRole
     name: kubernetes-dashboard-anonymous
   subjects:
   - kind: User
     name: system:anonymous
   EOF
   ```

   Output

   ```text
   clusterrolebinding.rbac.authorization.k8s.io/kubernetes-dashboard-anonymous created
   ```

4. Now copy the [token](#bearer-token) and paste it into Enter token field on log in screen.

   <p align="center">
      <img src="images/kube-dashboard-auth.png">
   </p>

5. Click Sign in button and that's it. You are now logged in as an admin.

   <p align="center">
      <img src="images/kube-dashboard-singin.png">
   </p>
