## Configure local hosts

### /etc/hosts

You can configure in your local machine `/etc/hosts` with the ip and name of VM's.

For you get ip of VM:

```
vboxmanage guestproperty enumerate hapx-node01 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate hapx-node02 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'

vboxmanage guestproperty enumerate kube-mast01 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate kube-mast02 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate kube-mast03 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'

vboxmanage guestproperty enumerate kube-node01 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate kube-node02 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate kube-node03 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'

vboxmanage guestproperty enumerate glus-node01 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate glus-node02 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
vboxmanage guestproperty enumerate glus-node03 | grep IP | grep -o -w -P -e '\d{1,3}\.\d{1,3}\.\d{1,3}\.\d{1,3}'
```

Ex.

```
192.168.254.254 gate-node01 gate-node01.kube.local

192.168.1.10 kube-mast01 kube-mast01.kube.local
192.168.1.11 kube-mast02 kube-mast02.kube.local
192.168.1.10 kube-mast03 kube-mast03.kube.local

192.168.2.10 kube-node01 kube-node01.kube.local
192.168.2.11 kube-node02 kube-node02.kube.local
192.168.2.10 kube-node03 kube-node03.kube.local

192.168.3.10 glus-node01 glus-node01.kube.local
192.168.3.11 glus-node02 glus-node02.kube.local
192.168.3.10 glus-node03 glus-node03.kube.local

192.168.4.10 hapx-node01 hapx-node01.kube.local
192.168.4.11 hapx-node02 hapx-node02.kube.local
```

### dnsmasq

If you are a using dnsmasq on your local machine execute this to use private DNS of this DEMO to domain 'kube.local'

```
$ echo "server=/kube.local/192.168.254.254" | sudo tee -a /etc/dnsmasq.d/server

$ sudo service dnsmasq restart
```