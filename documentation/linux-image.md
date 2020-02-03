# Linux Image

Remembering that the information mentioned here in this topic has relative importance in the plans you will adopt for your need, and you are't necessarily ruling this subject with an iron fist.

## Partitioning

The big decision to take when configuring Linux is how the hard drive space should be divided.

The design proposed here allows for dynamic growth and fine-tuning when needed. Being caught off guard in a scenario where there is no more storage space available, with no immediate option other than deleting files is never a good experience. The long-term life and growth of the system, as well as budgetary concerns, must be taken into account.

Isolating the root volume, especially for static data that does not grow much over time, is the central concern. Isolating the other directories in their own volumes will be the strategy adopted here so that their dynamic growth does not affect the root partition. Filling the root volume in a system is a very bad thing and should be avoided at all costs. By segregating partitions, we have a bunch of options to act, like increasing one partition and/or reducing another, for example, since the volume is not 100% occupied by the logical volumes (partitions).

Partitions may be increased later but this is how our volumes will be initially divided for the system installation:

| Partition   | Size   | Description                                                                                            |
|:-----------:|:------:|:-------------------------------------------------------------------------------------------------------|
| **boot**    | 512 Mb | Boot loader files (ex: kernel, initrd). Single space residing outside the Logical Volume Manager (LVM) |
| **root**    | 2 Gb   | Operational System (/bin, /lib, /etc, /sbin)                                                           |
| **home**    | 2 Gb   | User directories.                                                                                      |
| **opt**     | 1 Gb   | Static application packages.                                                                           |
| **tmp**     | 1 Gb   | Temporary files.                                                                                       |
| **usr**     | 10 Gb  | Secondary hierarchy for shared user data which access is restricted for read-only.                     |
| **var**     | 10 Gb  | "Variable" files, such as logs, databases, web pages, and e-mail files, container images, etc.         |

> Reference: http://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html

## Software

The installation of software packages that make up the base image is necessary to avoid repetition of work in the other VMs that will be created based on it.

Since we are using VirtualBox as our virtualization system, an important software that should compose every image is  [VirtualBox Guest Additions](https://docs.oracle.com/cd/E36500_01/E36502/html/qs-guest-additions.html), as well as its dependencies.

The softwares to be installed are the following:

* **build-essential**

    This package contains an informational list of packages which are considered essential for building Debian packages. This package also depends on the packages on that list, to make it easy to have the build-essential packages installed.

* **module-assistant**

    The module-assistant tool (also known as m-a) helps users and maintainers with managing external Linux kernel modules packaged for Debian. It also contains some infrastructure to be used by the build-scripts in the accompanying modules-source packages in Debian.

* **resolvconf**

    Resolvconf is a framework for keeping up to date the system's information about name servers. It sets itself up as the intermediary between programs that supply this information (such as ifup and ifdown, DHCP clients, the PPP daemon and local name servers) and programs that use this information (such as DNS caches and resolver libraries).

* **ntp**

    NTP, the Network Time Protocol, is used to keep computer clocks accurate by synchronizing them over the Internet or a local network, or by following an accurate hardware receiver that interprets GPS, DCF-77, NIST or similar time signals.

* **sudo**

    sudo is a program designed to allow a sysadmin to give limited root privileges to users and log root activity. The basic philosophy is to give as few privileges as possible but still allow people to get their work done.

* **cloud-init**

    Cloud-init provides a framework and tool to configure and customize virtual machine instances for Infrastructure-as-a-Service (IaaS) clouds platforms. It can, for example, set a default locale and hostname, generate SSH private host keys, install SSH public keys for logging into a default account, set up ephemeral mount points, and run user-provided scripts.

* **VirtualBox Guest Additions**

    The VirtualBox Guest Additions consist of device drivers and system applications that optimize the operating system for better performance and usability. One of the usability features required in this guide is automated logons, which is why you need to install the Guest Additions in the virtual machine.

> Reference: apt-cache show package-name

## Create image

Please follow the steps [here](create-linux-image.md)

In the following steps we will not adopt LVM and multiple volume partitioning, again remembering that the information mentioned here in this topic has relative importance in the plans that you will adopt for your need, and you are't necessarily ruling this subject with an iron fist.

### Or, if you prefer to download the base image

#### Debian

```shell
~$ cd ~/VirtualBox\ VMs/
~$ wget https://www.dropbox.com/s/xcsk4matlzmjo2m/debian-base-image.tar.bz2?dl=0 -O - | tar xvjf -
~$ vboxmanage registervm ~/VirtualBox\ VMs/debian-base-image/debian-base-image.vbox
```

#### Ubuntu

```shell
~$ cd ~/VirtualBox\ VMs/
~$ wget https://www.dropbox.com/s/hicmmy39gc3gog2/ubuntu-base-image.tar.bz2?dl=0 -O - | tar xvjf -
~$ vboxmanage registervm ~/VirtualBox\ VMs/ubuntu-base-image/ubuntu-base-image.vbox
```
