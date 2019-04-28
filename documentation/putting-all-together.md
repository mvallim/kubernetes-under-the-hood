## Putting it all together

### Configure Kube Master
```
ssh debian@kube-mast01.kube.local

sudo su -

cat <<EOF > kubeadm-config.yaml
apiVersion: kubeadm.k8s.io/v1beta1
kind: ClusterConfiguration
kubernetesVersion: stable-1.13
apiServer:
  certSANs:
  - "192.168.4.20"
controlPlaneEndpoint: "192.168.4.20:6443"
networking:
  podSubnet: 10.244.0.0/16
EOF

kubeadm init --config=kubeadm-config.yaml

mkdir -p $HOME/.kube

cp -i /etc/kubernetes/admin.conf $HOME/.kube/config

chown $(id -u):$(id -g) $HOME/.kube/config

kubectl apply -f https://raw.githubusercontent.com/coreos/flannel/a70459be0084506e4ec919aa1c114638878db11b/Documentation/kube-flannel.yml

ssh-keygen -t rsa -b 4096

ssh-copy-id debian@kube-mast02 #(default password: debian)

ssh-copy-id debian@kube-mast03 #(default password: debian)

~/bin/copy-certificates.sh

kubeadm token create --print-join-command
```
> The last command print the command to you join nodes on cluster, you will use this command to join master and wokers on cluster

#### Join second Kube Master
```
ssh debian@kube-mast02.kube.local

sudo su -

~/bin/move-certificates.sh

kubeadm join 192.168.4.20:6443 \
    --token ??? \
    --discovery-token-ca-cert-hash sha256:??? \
    --experimental-control-plane
```

#### Join third Kube Master
```
ssh debian@kube-mast03.kube.local

sudo su -

~/bin/move-certificates.sh

kubeadm join 192.168.4.20:6443 \
    --token ??? \
    --discovery-token-ca-cert-hash sha256:??? \
    --experimental-control-plane
```

### Join Kube Workers

#### Join first Kube Worker
```
ssh debian@kube-node01.kube.local

sudo su -

kubeadm join 192.168.4.20:6443 \
    --token ??? \
    --discovery-token-ca-cert-hash sha256:??? \
```

#### Join second Kube Worker
```
ssh debian@kube-node02.kube.local

sudo su -

kubeadm join 192.168.4.20:6443 \
    --token ??? \
    --discovery-token-ca-cert-hash sha256:??? \
```

#### Join third Kube Worker
```
ssh debian@kube-node03.kube.local

sudo su -

kubeadm join 192.168.4.20:6443 \
    --token ??? \
    --discovery-token-ca-cert-hash sha256:??? \
```