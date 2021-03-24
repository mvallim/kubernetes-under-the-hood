# How to setup an external etcd instance with TLS

<p align="center">
  <img src="images/etcd-logo.png">
</p>

_"etcd is a distributed key value store that provides a reliable way to store data across a cluster of machines. It’s open-source and available on GitHub. etcd gracefully handles leader elections during network partitions and will tolerate machine failure, including the leader."_

> Reference: https://coreos.com/etcd/docs/latest/

It is a daemon that runs on all servers in a cluster, providing a dynamic configuration record and allowing multiple configuration data to be shared between cluster members in a simple way.

Because data is stored in a key-value form in **etcd**, it is distributed and replicated automatically (with a **leader** being automatically selected). All changes to the stored data are reflected throughout the whole cluster.

**etcd** also provides a discovery service, allowing “deployed” applications to advertise the services they make available to all cluster nodes.

Communication with **etcd** is done through API calls, using JSON over HTTP. The API can be used directly (via curl or wget for example), or indirectly through etcdctl.

> Reference: https://etcd.io/

## Create the VMs

To initialize and configure our instances using cloud-init, we'll use the configuration files versioned at the data directory from our repository.

Notice we also make use of our `create-image.sh`(../create-image.sh) helper script, passing some files from inside the `data/kube/` directory as parameters.

- **Create the etcd nodes**

  ```console
  ~/kubernetes-under-the-hood$ for instance in etcd-node01 etcd-node02 etcd-node03; do
      ./create-image.sh \
          -k ~/.ssh/id_rsa.pub \
          -u etcd/user-data \
          -n etcd/network-config \
          -i etcd/post-config-interfaces \
          -r etcd/post-config-resources \
          -o ${instance} \
          -l debian \
          -b debian-base-image
  done
  ```

  Expected output:

  ```console
  Total translation table size: 0
  Total rockridge attributes bytes: 417
  Total directory bytes: 0
  Path table size(bytes): 10
  Max brk space used 0
  185 extents written (0 MB)
  0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
  Machine has been successfully cloned as "etcd-node01"
  Waiting for VM "etcd-node01" to power on...
  VM "etcd-node01" has been successfully started.
  Total translation table size: 0
  Total rockridge attributes bytes: 417
  Total directory bytes: 0
  Path table size(bytes): 10
  Max brk space used 0
  185 extents written (0 MB)
  0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
  Machine has been successfully cloned as "etcd-node02"
  Waiting for VM "etcd-node02" to power on...
  VM "etcd-node02" has been successfully started.
  Total translation table size: 0
  Total rockridge attributes bytes: 417
  Total directory bytes: 0
  Path table size(bytes): 10
  Max brk space used 0
  185 extents written (0 MB)
  0%...10%...20%...30%...40%...50%...60%...70%...80%...90%...100%
  Machine has been successfully cloned as "etcd-node03"
  Waiting for VM "etcd-node03" to power on...
  VM "etcd-node03" has been successfully started.
  ```

  **Parameters:**

  - **`-k`** is used to copy the **public key** from your host to the newly created VM.
  - **`-u`** is used to specify the **user-data** file that will be passed as a parameter to the command that creates the cloud-init ISO file we mentioned before (check the source code of the script for a better understanding of how it's used). Default is **`/data/user-data`**.
  - **`-m`** is used to specify the **meta-data** file that will be passed as a parameter to the command that creates the cloud-init ISO file we mentioned before (check the source code of the script for a better understanding of how it's used). Default is **`/data/meta-data`**.
  - **`-n`** is used to pass a configuration file that will be used by cloud-init to configure the **network** for the instance.
  - **`-i`** is used to pass a configuration file that our script will use to modify the **network interface** managed by **VirtualBox** that is attached to the instance that will be created from this image.
  - **`-r`** is used to pass a configuration file that our script will use to configure the **number of processors and amount of memory** that is allocated to our instance by **VirtualBox**.
  - **`-o`** is used to pass the **hostname** that will be assigned to our instance. This will also be the name used by **VirtualBox** to reference our instance.
  - **`-l`** is used to inform which Linux distribution (**debian** or **ubuntu**) configuration files we want to use (notice this is used to specify which folder under data is referenced). Default is **`debian`**.
  - **`-b`** is used to specify which **base image** should be used. This is the image name that was created on **VirtualBox** when we executed the installation steps from our [linux image](create-linux-image.md).
  - **`-s`** is used to pass a configuration file that our script will use to configure **virtual disks** on **VirtualBox**. You'll notice this is used only on the **Gluster** configuration step.
  - **`-a`** whether or not our instance **should be initialized** after it's created. Default is **`true`**.

### Understading the user-data file

The cloud-init etcd configuration file can be found [here](/data/debian/etcd/user-data). This configures and installs someone binaries.

```yaml
#cloud-config
write_files:

# CA ssh pub certificate
- path: /etc/ssh/ca.pub
  permissions: '0644'
  encoding: b64
  content: |
    c3NoLXJzYSBBQUFBQjNOemFDMXljMkVBQUFBREFRQUJBQUFDQVFERGozaTNSODZvQzNzZ0N3ZVRh
    R1dHZVZHRFpLbFdiOHM4QWVJVE9hOTB3NHl5UndSUWtBTWNGaWFNWGx5OEVOSDd0MHNpM0tFYnRZ
    M1B1ekpTNVMwTHY0MVFkaHlYMHJhUGxobTZpNnVDV3BvYWsycEF6K1ZFazhLbW1kZjdqMm5OTHlG
    Y3NQeVg0b0t0SlQrajh6R2QxWHRBWDBuS0JWOXFkOGNTTFFBZGpQVkdNZGxYdTNCZzdsNml3OHhK
    Ti9ld1l1Qm5DODZ5TlNiWFlDVVpLOE1oQUNLV2FMVWVnOSt0dXNyNTBSbGVRcGI0a2NKRE45LzFa
    MjhneUtORTRCVENYanEyTzVqRE1MRDlDU3hqNXJoNXRPUUlKREFvblIrMnljUlVnZTltc2hIQ05D
    VWU2WG16OFVJUFJ2UVpPNERFaHpHZ2N0cFJnWlhQajRoMGJoeGVMekUxcFROMHI2Q29GMDVpOFB0
    QXd1czl1K0tjUHVoQlgrVm9UbW1JNmRBTStUQkxRUnJ3SUorNnhtM29nWEMwYVpjdkdCVUVTcVll
    QjUyU0xjZEwyNnBKUlBrVjZYQ0Qyc3RleG5uOFREUEdjYnlZelFnaGNlYUYrb0psdWE4UDZDSzV2
    VStkNlBGK2o1aEE2NGdHbDQrWmw0TUNBcXdNcnBySEhpd2E3bzF0MC9JTmdoYlFvUUdSU3haQXMz
    UHdYcklMQ0xUeGN6V29UWHZIWUxuRXRTWW42MVh3SElldWJrTVhJamJBSysreStKWCswcm02aHRN
    N2h2R2QzS0ZvU1N4aDlFY1FONTNXWEhMYXBHQ0o0NGVFU3NqbVgzN1NwWElUYUhEOHJQRXBia0E0
    WWJzaVVoTXZPZ0VCLy9MZ1d0R2kvRVRxalVSUFkvWGRTVTR5dFE9PSBjYUBrdWJlLmRlbW8K

apt:
  sources_list: |
    deb http://deb.debian.org/debian/ $RELEASE main contrib non-free
    deb-src http://deb.debian.org/debian/ $RELEASE main contrib non-free

    deb http://deb.debian.org/debian/ $RELEASE-updates main contrib non-free
    deb-src http://deb.debian.org/debian/ $RELEASE-updates main contrib non-free

    deb http://deb.debian.org/debian-security $RELEASE/updates main
    deb-src http://deb.debian.org/debian-security $RELEASE/updates main
  conf: |
    APT {
      Get {
        Assume-Yes "true";
        Fix-Broken "true";
      };
    };

packages:
  - apt-transport-https
  - ca-certificates
  - gnupg2
  - software-properties-common
  - curl

runcmd:
  - [ chown, -R, 'debian:debian', '/home/debian' ]
    # SSH server to trust the CA
  - echo '\nTrustedUserCAKeys /etc/ssh/ca.pub' | tee -a /etc/ssh/sshd_config

users:
- name: debian
  gecos: Debian User
  sudo: ALL=(ALL) NOPASSWD:ALL
  shell: /bin/bash
  lock_passwd: true
- name: root
  lock_passwd: true

locale: en_US.UTF-8

timezone: UTC

ssh_deletekeys: 1

package_upgrade: true

ssh_pwauth: true

manage_etc_hosts: false

fqdn: #HOSTNAME#.kube.demo

hostname: #HOSTNAME#

power_state:
  mode: reboot
  timeout: 30
  condition: true
```

### Configure your local routing

You need to add a route to your local machine to access the internal network of **Virtualbox**.

```console
~$ sudo ip route add 192.168.4.0/27 via 192.168.4.30 dev vboxnet0
~$ sudo ip route add 192.168.4.32/27 via 192.168.4.62 dev vboxnet0
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

Expected output:

```console
Linux busybox 4.9.0-15-amd64 #1 SMP Debian 4.9.258-1 (2021-03-08) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
```

### Creating certificates

1. Create the server requests certificates to etcd nodes

    ```console
    debian@busybox:~/certificates$ for instance in etcd-node01 etcd-node02 etcd-node03; do
        CN=${instance} SAN=DNS:${instance},DNS:${instance}.kube.demo,DNS:*.kube.demo \
            openssl req -newkey rsa:2048 -nodes \
                -keyout ${instance}-key.pem \
                -config config.conf \
                -out ${instance}-cert.csr
    done
    ```

    Expected output:

    ```text
    Generating a RSA private key
    .....................+++++
    .................................................+++++
    writing new private key to 'etcd-node01-key.pem'
    -----
    Generating a RSA private key
    .......................+++++
    ......................................................................+++++
    writing new private key to 'etcd-node02-key.pem'
    -----
    Generating a RSA private key
    .................................+++++
    ........................+++++
    writing new private key to 'etcd-node03-key.pem'
    -----
    ```

2. Create the peer requests certificates to etcd nodes

    ```console
    debian@busybox:~/certificates$ for instance in etcd-node01-peer etcd-node02-peer etcd-node03-peer; do
        CN=${instance} SAN=DNS:${instance},DNS:${instance}.kube.demo,DNS:*.kube.demo \
            openssl req -newkey rsa:2048 -nodes \
                -keyout ${instance}-key.pem \
                -config config.conf \
                -out ${instance}-cert.csr
    done
    ```

    Expected output:

    ```text
    Generating a RSA private key
    .......+++++
    ....................................................................+++++
    writing new private key to 'etcd-node01-peer-key.pem'
    -----
    Generating a RSA private key
    ......................................................................................+++++
    ..........................................................................+++++
    writing new private key to 'etcd-node02-peer-key.pem'
    -----
    Generating a RSA private key
    ........................+++++
    ................................+++++
    writing new private key to 'etcd-node03-peer-key.pem'
    -----
    ```

3. Sign the server certificates using your own CA

    ```console
    debian@busybox:~/certificates$ for instance in etcd-node01 etcd-node02 etcd-node03; do
        CN=${instance} SAN=DNS:${instance},DNS:${instance}.kube.demo,DNS:*.kube.demo \
            openssl x509 -req \
                -extfile config.conf \
                -extensions server \
                -in ${instance}-cert.csr \
                -CA ca-etcd-cert.pem \
                -CAkey ca-etcd-key.pem \
                -CAcreateserial \
                -out ${instance}-cert.pem \
                -days 3650 -sha256
    done
    ```

    Expected output:

    ```text
    Signature ok
    subject=C = BR, ST = SP, L = Campinas, O = "Kubernetes, Labs", OU = Labs, CN = etcd-node01
    Getting CA Private Key
    Signature ok
    subject=C = BR, ST = SP, L = Campinas, O = "Kubernetes, Labs", OU = Labs, CN = etcd-node02
    Getting CA Private Key
    Signature ok
    subject=C = BR, ST = SP, L = Campinas, O = "Kubernetes, Labs", OU = Labs, CN = etcd-node03
    Getting CA Private Key
    ```

4. Sign the peer certificates using your own CA

    ```console
    debian@busybox:~/certificates$ for instance in etcd-node01-peer etcd-node02-peer etcd-node03-peer; do
        CN=${instance} SAN=DNS:${instance},DNS:${instance}.kube.demo,DNS:*.kube.demo \
            openssl x509 -req \
                -extfile config.conf \
                -extensions peer \
                -in ${instance}-cert.csr \
                -CA ca-etcd-cert.pem \
                -CAkey ca-etcd-key.pem \
                -CAcreateserial \
                -out ${instance}-cert.pem \
                -days 3650 -sha256
    done
    ```

    Expected output:

    ```text
    Signature ok
    subject=C = BR, ST = SP, L = Campinas, O = "Kubernetes, Labs", OU = Labs, CN = etcd-node01-peer
    Getting CA Private Key
    Signature ok
    subject=C = BR, ST = SP, L = Campinas, O = "Kubernetes, Labs", OU = Labs, CN = etcd-node02-peer
    Getting CA Private Key
    Signature ok
    subject=C = BR, ST = SP, L = Campinas, O = "Kubernetes, Labs", OU = Labs, CN = etcd-node03-peer
    Getting CA Private Key
    ```

5. Verify the signatures

    ```console
    debian@busybox:~/certificates$ for instance in etcd-node01 etcd-node01-peer etcd-node02 etcd-node02-peer etcd-node03 etcd-node03-peer; do
        openssl verify -CAfile ca-etcd-chain-cert.pem ${instance}-cert.pem
    done
    ```

    Expected output:

    ```text
    etcd-node01-cert.pem: OK
    etcd-node01-peer-cert.pem: OK
    etcd-node02-cert.pem: OK
    etcd-node02-peer-cert.pem: OK
    etcd-node03-cert.pem: OK
    etcd-node03-peer-cert.pem: OK
    ```

6. Copy the certificate to the etcd instances

    ```console
    debian@busybox:~/certificates$ for instance in etcd-node01 etcd-node02 etcd-node03; do
        scp ca-etcd-chain-cert.pem ${instance}-*.pem debian@${instance}:~/.
    done
    ```

    Expected output:

    ```text
    ca-etcd-chain-cert.pem              100% 2883     2.9MB/s   00:00
    etcd-node01-cert.pem                100% 1651     1.4MB/s   00:00
    etcd-node01-key.pem                 100% 1704     1.8MB/s   00:00
    etcd-node01-peer-cert.pem           100% 1679     2.4MB/s   00:00
    etcd-node01-peer-key.pem            100% 1704     2.3MB/s   00:00
    ca-etcd-chain-cert.pem              100% 2883     2.5MB/s   00:00
    etcd-node02-cert.pem                100% 1651     1.5MB/s   00:00
    etcd-node02-key.pem                 100% 1704     2.0MB/s   00:00
    etcd-node02-peer-cert.pem           100% 1679     2.0MB/s   00:00
    etcd-node02-peer-key.pem            100% 1704     2.1MB/s   00:00
    ca-etcd-chain-cert.pem              100% 2883     2.2MB/s   00:00
    etcd-node03-cert.pem                100% 1651     1.4MB/s   00:00
    etcd-node03-key.pem                 100% 1704     1.5MB/s   00:00
    etcd-node03-peer-cert.pem           100% 1679     1.7MB/s   00:00
    etcd-node03-peer-key.pem            100% 1704     1.7MB/s   00:00
    ```

### Running Commands in Parallel with tmux

#### Split panes horizontally

To split a pane horizontally, press **ctrl+b** and **'** (single quotation mark). Let's go!

```console
debian@busybox:~$ tmux
```

```console
debian@busybox:~$ ssh debian@etcd-node01
```

> `ctrl+b` `"`

```console
debian@busybox:~$ ssh debian@etcd-node02
```

> `ctrl+b` `"`

```console
debian@busybox:~$ ssh debian@etcd-node03
```

> `ctrl+b` `"`

#### Send commands to all panes

Press **ctrl+b** and **shit+:**, type the following command and hit ENTER:

`setw synchronize-panes`

1. Create `etcd` user and group to run the service

    ```console
    sudo groupadd --system etcd
    sudo useradd -s /sbin/nologin --system -g etcd etcd
    ```

2. Create directories to store `etcd` data

    ```console
    sudo mkdir -p /var/lib/etcd/
    sudo chown etcd:etcd /var/lib/etcd
    ```

3. Create a directory to hold the certificate files

    ```console
    sudo mkdir /etc/etcd
    sudo mv *.pem /etc/etcd/.
    sudo chmod +r /etc/etcd/*.pem
    sudo chown etcd:etcd /etc/etcd/*.pem
    ```

4. Download and install the `etcd` binaries

    ```console
    curl -L --progress \
        https://github.com/etcd-io/etcd/releases/download/v3.4.7/etcd-v3.4.7-linux-amd64.tar.gz \
        -o /tmp/etcd-v3.4.7-linux-amd64.tar.gz

    tar xvzf /tmp/etcd-v3.4.7-linux-amd64.tar.gz

    sudo mv etcd-v3.4.7-linux-amd64/etcd* /usr/local/bin/.
    sudo chown root:root /usr/local/bin/etcd*

    rm -rf etcd-v3.4.7-linux-amd64
    ```

5. Create a unit service file to run on `systemd`

    ```console
    ETCD_NAME=$(hostname -s | tr -d '[:space:]')

    cat <<EOF | sudo tee -a /etc/systemd/system/etcd.service
    [Unit]
    Description=etcd
    Documentation=https://github.com/coreos/etcd
    Conflicts=etcd.service

    [Service]
    Type=notify
    Restart=always
    RestartSec=5s
    LimitNOFILE=40000
    TimeoutStartSec=0
    User=etcd
    Group=etcd

    ExecStart=/usr/local/bin/etcd --name ${ETCD_NAME} \\
        --data-dir /var/lib/etcd \\
        --listen-client-urls https://0.0.0.0:2379 \\
        --listen-peer-urls https://0.0.0.0:2380 \\
        --advertise-client-urls https://${ETCD_NAME}.kube.demo:2379 \\
        --initial-advertise-peer-urls https://${ETCD_NAME}.kube.demo:2380 \\
        --initial-cluster etcd-node01=https://etcd-node01.kube.demo:2380,etcd-node02=https://etcd-node02.kube.demo:2380,etcd-node03=https://etcd-node03.kube.demo:2380 \\
        --initial-cluster-token BHGUXFgqJJfS38HCuVy4Xvn8DuDLu8Hd \\
        --initial-cluster-state new \\
        --client-cert-auth \\
        --trusted-ca-file /etc/etcd/ca-etcd-chain-cert.pem \\
        --cert-file /etc/etcd/${ETCD_NAME}-cert.pem \\
        --key-file /etc/etcd/${ETCD_NAME}-key.pem \\
        --peer-client-cert-auth \\
        --peer-trusted-ca-file /etc/etcd/ca-etcd-chain-cert.pem \\
        --peer-cert-file /etc/etcd/${ETCD_NAME}-peer-cert.pem \\
        --peer-key-file /etc/etcd/${ETCD_NAME}-peer-key.pem

    [Install]
    WantedBy=multi-user.target
    EOF
    ```

6. Start and run the `etcd` servers

   ```console
   sudo systemctl daemon-reload
   sudo systemctl enable etcd.service
   sudo systemctl start etcd.service
   ```

7. Check the `etcd` status

   ```console
   ETCD_NAME=$(hostname -s | tr -d '[:space:]')

   etcdctl member list \
        --cacert=/etc/etcd/ca-etcd-chain-cert.pem \
        --cert=/etc/etcd/${ETCD_NAME}-peer-cert.pem \
        --key=/etc/etcd/${ETCD_NAME}-peer-key.pem \
        -w table
    ```

   Expected output:

   ```text
    +------------------+---------+-------------+------------------------------------+------------------------------------+------------+
    |        ID        | STATUS  |    NAME     |             PEER ADDRS             |            CLIENT ADDRS            | IS LEARNER |
    +------------------+---------+-------------+------------------------------------+------------------------------------+------------+
    |  8dc5f1bc33f2f56 | started | etcd-node02 | https://etcd-node02.kube.demo:2380 | https://etcd-node02.kube.demo:2379 |      false |
    | 77508fdcfa570432 | started | etcd-node01 | https://etcd-node01.kube.demo:2380 | https://etcd-node01.kube.demo:2379 |      false |
    | eefbe5085b970e3a | started | etcd-node03 | https://etcd-node03.kube.demo:2380 | https://etcd-node03.kube.demo:2379 |      false |
    +------------------+---------+-------------+------------------------------------+------------------------------------+------------+
   ```
