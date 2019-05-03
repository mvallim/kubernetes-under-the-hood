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

### Deploy
```
git clone git@github.com:gluster/gluster-kubernetes.git
```

```
cd deploy

vi topology
```

```
kubectl create namespace glusterfs
```

```
./gk-deploy --ssh-keyfile ~/.ssh/id_rsa --ssh-user root --cli kubectl \
    --templates_dir ./kube-templates --namespace glusterfs \
    topology.json
```

### Configure Storage Class

StorageClass manifest:

```
apiVersion: storage.k8s.io/v1
kind: StorageClass
metadata:
  name: glusterfs-storage
  namespace: glusterfs
provisioner: kubernetes.io/glusterfs
allowVolumeExpansion: true
reclaimPolicy: Retain
parameters:
  resturl: "http://10.244.xxx.xxx:8080"
  restuser: "admin"
  restuserkey: "none"
  volumetype: "replicate:3"
```

```
kubectl create -f glusterfs-storageclass.yaml
```
