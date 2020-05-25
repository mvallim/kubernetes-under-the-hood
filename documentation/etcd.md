# How to setup the external etcd with TLS

<p align="center">
  <img src="images/etcd-logo.png">
</p>

*"etcd is a distributed key value store that provides a reliable way to store data across a cluster of machines. It’s open-source and available on GitHub. etcd gracefully handles leader elections during network partitions and will tolerate machine failure, including the leader."*

> Reference: https://coreos.com/etcd/docs/latest/

It is a daemon that runs on all servers in a cluster, providing a dynamic configuration record and allowing multiple configuration data to be shared between cluster members in a simple way.

Because data is stored in a key-value form in **etcd**, it is distributed and replicated automatically (with a **leader** being automatically selected). All changes to the stored data are reflected throughout the whole cluster.

**etcd** also provides a discovery service, allowing “deployed” applications to advertise the services they make available to all cluster nodes.

Communication with **etcd** is done through API calls, using JSON over HTTP. The API can be used directly (via curl or wget for example), or indirectly through etcdctl.

> Reference: https://etcd.io/

## Create the VMs

To initialize and configure our instances using cloud-init, we'll use the configuration files versioned at the data directory from our repository.

Notice we also make use of our `create-image.sh` helper script, passing some files from inside the `data/kube/` directory as parameters.

* **Create the Masters**

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

  **Expected output:**

  ```text
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

  * **`-k`** is used to copy the **public key** from your host to the newly created VM.
  * **`-u`** is used to specify the **user-data** file that will be passed as a parameter to the command that creates the cloud-init ISO file we mentioned before (check the source code of the script for a better understanding of how it's used). Default is **`/data/user-data`**.
  * **`-m`** is used to specify the **meta-data** file that will be passed as a parameter to the command that creates the cloud-init ISO file we mentioned before (check the source code of the script for a better understanding of how it's used). Default is **`/data/meta-data`**.
  * **`-n`** is used to pass a configuration file that will be used by cloud-init to configure the **network** for the instance.
  * **`-i`** is used to pass a configuration file that our script will use to modify the **network interface** managed by **VirtualBox** that is attached to the instance that will be created from this image.
  * **`-r`** is used to pass a configuration file that our script will use to configure the **number of processors and amount of memory** that is allocated to our instance by **VirtualBox**.
  * **`-o`** is used to pass the **hostname** that will be assigned to our instance. This will also be the name used by **VirtualBox** to reference our instance.
  * **`-l`** is used to inform which Linux distribution (**debian** or **ubuntu**) configuration files we want to use (notice this is used to specify which folder under data is referenced). Default is **`debian`**.
  * **`-b`** is used to specify which **base image** should be used. This is the image name that was created on **VirtualBox** when we executed the installation steps from our [linux image](create-linux-image.md).
  * **`-s`** is used to pass a configuration file that our script will use to configure **virtual disks** on **VirtualBox**. You'll notice this is used only on the **Gluster** configuration step.
  * **`-a`** whether or not our instance **should be initialized** after it's created. Default is **`true`**.

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
Linux busybox 4.9.0-11-amd64 #1 SMP Debian 4.9.189-3+deb9u2 (2019-11-11) x86_64

The programs included with the Debian GNU/Linux system are free software;
the exact distribution terms for each program are described in the
individual files in /usr/share/doc/*/copyright.

Debian GNU/Linux comes with ABSOLUTELY NO WARRANTY, to the extent
permitted by applicable law.
```

### Creating certificates

1. Create certificate template

    ```console
    debian@busybox:~$ mkdir certificates
    ```

    ```console
    debian@busybox:~$ cd certificates
    ```

    ```console
    debian@busybox:~/certificates$ cat <<EOF > config.conf
    [ req ]
    default_bits            = 2048
    default_md              = sha256
    distinguished_name      = dn
    prompt                  = no

    [ dn ]
    C                       = BR
    ST                      = SP
    L                       = Campinas
    O                       = Kubernetes, Labs
    OU                      = Labs
    CN                      = \${ENV::CN}

    [ root ]
    basicConstraints        = critical,CA:TRUE
    subjectKeyIdentifier    = hash
    authorityKeyIdentifier  = keyid:always,issuer
    keyUsage                = critical,digitalSignature,keyEncipherment,keyCertSign,cRLSign

    [ ca ]
    basicConstraints        = critical,CA:TRUE,pathlen:0
    subjectKeyIdentifier    = hash
    authorityKeyIdentifier  = keyid:always,issuer:always
    keyUsage                = critical,digitalSignature,keyEncipherment,keyCertSign,cRLSign

    [ server ]
    subjectKeyIdentifier    = hash
    basicConstraints        = critical,CA:FALSE
    extendedKeyUsage        = serverAuth
    keyUsage                = critical,keyEncipherment,dataEncipherment
    authorityKeyIdentifier  = keyid,issuer:always
    subjectAltName          = DNS:localhost,\${ENV::SAN},IP:127.0.0.1,IP:127.0.1.1

    [ peer ]
    subjectKeyIdentifier    = hash
    basicConstraints        = critical,CA:FALSE
    extendedKeyUsage        = serverAuth,clientAuth
    keyUsage                = critical,keyEncipherment,dataEncipherment
    authorityKeyIdentifier  = keyid,issuer:always
    subjectAltName          = DNS:localhost,\${ENV::SAN},IP:127.0.0.1,IP:127.0.1.1

    [ user ]
    subjectKeyIdentifier    = hash
    basicConstraints        = critical,CA:FALSE
    extendedKeyUsage        = clientAuth
    keyUsage                = critical,keyEncipherment,dataEncipherment
    authorityKeyIdentifier  = keyid,issuer:always
    EOF
    ```

2. Create Root CA certificate

    ```console
    debian@busybox:~/certificates$ CN="Root, CA" SAN= \
        openssl req -x509 -newkey rsa:2048 -nodes \
            -keyout root-key.pem \
            -days 3650 \
            -config config.conf \
            -extensions root \
            -out root-cert.pem
    ```

    Expected output:

    ```text
    Generating a RSA private key
    ...........................................................+++++
    ...............+++++
    writing new private key to 'root-cert.pem'
    -----
    ```

3. Create request intermediate etcd CA certificate

    ```console
    debian@busybox:~/certificates$ CN="Etcd, CA" SAN= \
        openssl req -newkey rsa:2048 -nodes \
            -keyout ca-etcd-key.pem \
            -config config.conf \
            -out ca-etcd-cert.csr
    ```

    Expected output:

    ```text
    Generating a RSA private key
    ..........+++++
    ......................................................................................+++++
    writing new private key to 'ca-etcd-key.pem'
    -----
    ```

4. Sing intermediate etcd CA certificate with root CA

    ```console
    debian@busybox:~/certificates$ CN="Etcd, CA" SAN= \
        openssl x509 -req \
            -extfile config.conf \
            -extensions ca \
            -in ca-etcd-cert.csr \
            -CA root-cert.pem \
            -CAkey root-key.pem \
            -CAcreateserial \
            -out ca-etcd-cert.pem \
            -days 3650 -sha256
    ```

    Expected output:

    ```text
    Signature ok
    subject=C = BR, ST = SP, L = Campinas, O = "Kubernetes, Labs", OU = Labs, CN = "Etcd, CA"
    Getting CA Private Key
    ```

5. Create chain intermediate certificate etcd CA

    ```console
    debian@busybox:~/certificates$ cat ca-etcd-cert.pem root-cert.pem > ca-etcd-chain-cert.pem
    ```

6. Create requests server certificates to etcd nodes

    ```console
    debian@busybox:~/certificates$ for instance in etcd-node01 etcd-node02 etcd-node03; do
        CN=${instance} SAN=DNS:${instance},DNS:${instance}.kube.demo \
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
    ..............................................................................................................................................+++++
    writing new private key to 'etcd-node02-key.pem'
    -----
    Generating a RSA private key
    .................................+++++
    ........................+++++
    writing new private key to 'etcd-node03-key.pem'
    -----
    ```

7. Sing certificates using your own etcd CA

    ```console
    debian@busybox:~/certificates$ for instance in etcd-node01 etcd-node02 etcd-node03; do
        CN=${instance} SAN=DNS:${instance},DNS:${instance}.kube.demo \
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

8. Verify signatures using your own etcd chain cert

    ```console
    debian@busybox:~/certificates$ for instance in etcd-node01 etcd-node02 etcd-node03; do
        openssl verify -CAfile ca-etcd-chain-cert.pem ${instance}-cert.pem
    done
    ```

    Expected output:

    ```text
    etcd-node01-cert.pem: OK
    etcd-node02-cert.pem: OK
    etcd-node03-cert.pem: OK
    ```

9. Copy certificate to instances

    ```console
    debian@busybox:~/certificates$ for instance in etcd-node01 etcd-node02 etcd-node03; do
        scp ca-etcd-chain-cert.pem ${instance}-*.pem debian@${instance}:~/.
    done
    ```

    Expected output:

    ```text
    ca-etcd-chain-cert.pem          100% 1200     1.2MB/s   00:00
    etcd-node01-cert.pem            100% 1623     1.2MB/s   00:00
    etcd-node01-key.pem             100% 1708     1.8MB/s   00:00
    ca-etcd-chain-cert.pem          100% 1200     1.0MB/s   00:00
    etcd-node02-cert.pem            100% 1623     1.6MB/s   00:00
    etcd-node02-key.pem             100% 1704     1.5MB/s   00:00
    ca-etcd-chain-cert.pem          100% 1200     1.1MB/s   00:00
    etcd-node03-cert.pem            100% 1623     1.7MB/s   00:00
    etcd-node03-key.pem             100% 1704     1.0MB/s   00:00
    ```

### Running Commands in Parallel with tmux

#### Split panes horizontally

To split a pane horizontally, press **ctrl+b** and **”** (single quotation mark).

Let's go

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

#### Send commands to all panes

Press **ctrl+b** and **shit+:** type the following command and hit ENTER:

`setw synchronize-panes`

1. Create user and group `etcd` to run service

    ```console
    sudo groupadd --system etcd
    sudo useradd -s /sbin/nologin --system -g etcd etcd
    ```

2. Create directories to stora data `etcd`

    ```console
    sudo mkdir -p /var/lib/etcd/
    sudo chown etcd:etcd /var/lib/etcd
    ```

3. Create directory to certificate files and copy files

    ```console
    sudo mkdir /etc/etcd
    sudo mv *.pem /etc/etcd/.
    sudo chmod +r /etc/etcd/*.pem
    sudo chown etcd:etcd /etc/etcd/*.pem
    ```

4. Download and install binaries `etcd`

    ```console
    curl -L --progress \
        https://github.com/etcd-io/etcd/releases/download/v3.4.7/etcd-v3.4.7-linux-amd64.tar.gz \
        -o /tmp/etcd-v3.4.7-linux-amd64.tar.gz

    tar xvzf /tmp/etcd-v3.4.7-linux-amd64.tar.gz

    sudo mv etcd-v3.4.7-linux-amd64/etcd* /usr/local/bin/.
    sudo chown root:root /usr/local/bin/etcd*

    rm -rf etcd-v3.4.7-linux-amd64
    ```

5. Create unit service file to run on `systemd`

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
        --listen-client-urls https://0.0.0.0:2379,https://localhost:2379 \\
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

7. Verification

    ```console
    ETCD_NAME=$(hostname -s | tr -d '[:space:]')

    etcdctl member list \
        --cacert=/etc/etcd/ca-etcd-chain-cert.pem \
        --cert=/etc/etcd/${ETCD_NAME}-peer-cert.pem \
        --key=/etc/etcd/${ETCD_NAME}-peer-key.pem
    ```

    Expected output

    ```text
    77508fdcfa570432, started, etcd-node01, https://etcd-node01.kube.demo:2380, https://192.168.1.75:2379, false
    8dc5f1bc33f2f56b, started, etcd-node02, https://etcd-node02.kube.demo:2380, https://192.168.1.128:2379, false
    eefbe5085b970e3a, started, etcd-node03, https://etcd-node03.kube.demo:2380, https://192.168.1.121:2379, false
    ```
