## Cloud-Init
*"cloud-init is developed and released as free software under both the GPLv3 open source license and Apache License version 2.0. It was originally designed for the Ubuntu distribution of Linux in Amazon EC2, but is now supported on many Linux and UNIX distributions in every major cloud."*
> Reference: https://cloud-init.io/

### Overview
`cloud-init` is a utility for instance initialization. It allows automatic configuration of instances as it is initialized, transforming a generic image of Linux into a configured server in a few seconds, quickly and easily.

The `cloud-init` program that is available in the latest Linux distributions and is capable of running service, user, and package install configurations. One of the most popular formats for [`user-data`](https://cloudinit.readthedocs.io/en/latest/topics/examples.html) scripts is the` cloud-config` file format.

`cloud-config` files are special scripts designed to be run by the` cloud-init` process. They are usually used for initial setup on the first startup of a server.

### Capabilities
* run commands: executes a list of commands with output to the console.
* configure ssh keys: add an entry for `~/.ssh/authorized_keys` to the configured user.
* install packages: install additional packages on first startup.
* configure network: upgrade `/etc/hosts`, host name, etc.
* write files: write arbitrary files to disk.
* add repository: add an apt or yum repository.
* create user and groups: add groups and users to the system and set properties for them.
* perform upgrade: upgrade all packages.
* reboot: reboot or shut down when finished with cloud-init.

### Seed ISO
The initialization of the data source used here will be [`nocloud`](https://cloudinit.readthedocs.io/en/latest/topics/datasources/nocloud.html). To boot the system in this way, you need to create an ISO file with a `meta-data` file and a `user-data` file, as shown below:

```
genisoimage -input-charset utf-8 \
  -output hostname-cidata.iso \
  -volid cidata -joliet -rock meta-data user-data
```

Attach the generated `hostname-cidata.iso` to your virtual machine and reboot to `cloud-init` to take effect.

> You can observe this procedure inside the script [`create-image.sh`](/create-image.sh).