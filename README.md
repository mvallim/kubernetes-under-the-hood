```
$ cd ~/VirtualBox\ VMs/

$ wget https://www.dropbox.com/s/v6h0sedqt3za9pl/image-base.tar.bz2?dl=0

$ tar xvjf image-base.tar.bz2

$ vboxmanage registervm ~/VirtualBox\ VMs/image-base/image-base.vbox

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/gate/user-data \
    -n ~/Projects/images/data/gate/network-config \
    -p ~/Projects/images/data/gate/post-config-interfaces \
    -o gate-node01 \
    -b image-base

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/hapx/user-data \
    -n ~/Projects/images/data/hapx/network-config \
    -p ~/Projects/images/data/hapx/post-config-interfaces \
    -o hapx-node01 \
    -b image-base

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/hapx/user-data \
    -n ~/Projects/images/data/hapx/network-config \
    -p ~/Projects/images/data/hapx/post-config-interfaces \
    -o hapx-node02 \
    -b image-base

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/kube/user-data \
    -n ~/Projects/images/data/kube/network-config \
    -p ~/Projects/images/data/kube-mast/post-config-interfaces \
    -o kube-mast01 \
    -b image-base

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/kube/user-data \
    -n ~/Projects/images/data/kube/network-config \
    -p ~/Projects/images/data/kube-mast/post-config-interfaces \
    -o kube-mast02 \
    -b image-base

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/kube/user-data \
    -n ~/Projects/images/data/kube/network-config \
    -p ~/Projects/images/data/kube-mast/post-config-interfaces \
    -o kube-mast03 \
    -b image-base

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/kube/user-data \
    -n ~/Projects/images/data/kube/network-config \
    -p ~/Projects/images/data/kube-node/post-config-interfaces \
    -o kube-node01 \
    -b image-base

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/kube/user-data \
    -n ~/Projects/images/data/kube/network-config \
    -p ~/Projects/images/data/kube-node/post-config-interfaces \
    -o kube-node02 \
    -b image-base

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/kube/user-data \
    -n ~/Projects/images/data/kube/network-config \
    -p ~/Projects/images/data/kube-node/post-config-interfaces \
    -o kube-node03 \
    -b image-base

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/glus/user-data \
    -n ~/Projects/images/data/glus/network-config \
    -p ~/Projects/images/data/glus/post-config-interfaces \
    -o kube-glus01 \
    -b image-base

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/glus/user-data \
    -n ~/Projects/images/data/glus/network-config \
    -p ~/Projects/images/data/glus/post-config-interfaces \
    -o kube-glus02 \
    -b image-base

$ ./create-image.sh \
    -s ~/.ssh/id_rsa.pub \
    -u ~/Projects/images/data/glus/user-data \
    -n ~/Projects/images/data/glus/network-config \
    -p ~/Projects/images/data/glus/post-config-interfaces \
    -o kube-glus03 \
    -b image-base
```
