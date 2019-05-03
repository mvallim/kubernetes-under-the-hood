## Heketi

*Heketi provides a RESTful management interface which can be used to manage the life cycle of GlusterFS volumes. With Heketi, cloud services like OpenStack Manila, Kubernetes, and OpenShift can dynamically provision GlusterFS volumes with any of the supported durability types. Heketi will automatically determine the location for bricks across the cluster, making sure to place bricks and its replicas across different failure domains. Heketi also supports any number of GlusterFS clusters, allowing cloud services to provide network file storage without being limited to a single GlusterFS cluster.”*
> Reference: https://github.com/heketi/heketi

### Overview

#### Create Volume

<p align="center">
  <img src="images/heketi-create-volume.gif">
</p>

#### Expand Volume

<p align="center">
  <img src="images/heketi-expand-volume.gif">
</p>

### Install

#### Deploy
1. Run
   ```
   git clone git@github.com:gluster/gluster-kubernetes.git
   ```

2. Edit
   ```
   cd deploy
   
   vi topology
   ```

3. Create
   ```
   kubectl create namespace glusterfs
   ```

4. Deploy
   ```
   ./gk-deploy --ssh-keyfile ~/.ssh/id_rsa --ssh-user root --cli kubectl \
       --templates_dir ./kube-templates --namespace glusterfs \
       topology.json
   ```

5. Query
   ```
   kubectl get pods -n glusterfs
   ```

   Output:
   ```
   ```

#### Configure Storage Class

StorageClass manifest:

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: glusterfs-storage
provisioner: kubernetes.io/glusterfs
allowVolumeExpansion: true
reclaimPolicy: Retain
parameters:
  resturl: "http://10.244.xxx.xxx:8080"
  restuser: "admin"
  restuserkey: "none"
  volumetype: "replicate:3"
```

1. Run
   ```
   kubectl create -f glusterfs-storageclass.yaml
   ```

2. Query:
   ```
   kubectl get storageclass
   ```

   Output:
   ```
   ```

#### Create Volume

PersistentVolumeClaim manifest:
```
apiVersion: v1
kind: PersistentVolumeClaim
metadata:
  name: persistent-volume-0001
  annotations:
    volume.beta.kubernetes.io/storage-class: glusterfs-storage
spec:
  accessModes:
  - ReadWriteMany
  resources:
    requests:
      storage: 2Gi
```

1. Run
   ```
   kubectl create -f https://raw.githubusercontent.com/mvallim/kubernetes-under-the-hood/master/heketi/persistent-volume-claim.yaml
   ```

2. Query:
   ```
   kubectl get persistentvolumeclaim
   ```

   Output:
   ```
   ```

#### Expand Volume
1. Run:
   ```
   kubectl get persistentvolumeclaim persistent-volume-0001 -o yaml > persistent-volume-claim.yaml
   ```

2. Edit file:
   ```
   kubectl apply -f persistent-volume-claim.yaml
   ```

3. Query:
   ```
   kubectl get persistentvolumeclaim
   ```
   
   Output:
   ```
   ```

#### Cleaning up
1. Run:
   ```
   kubectl delete persistentvolumeclaim persistent-volume-0001
   ```

2. Query:
   ```
   kubectl get persistentvolumeclaim
   ```
   
   Output:
   ```
   ```
