## Getting Started

### Creating Linux base image

#### Partitioning

The big decision about configuring Linux is how hard drive space is divided.

This design allows for dynamic growth and fine-tuning when needed. Being caught off guard with a scenario there is no more storage space available, with no immediate option other than deleting files is never a good experience. The long-term life and growth of the system, as well as the budgetary concerns, must be taken into account.

Isolating root volume, especially for static data that does not grow much over time, is the central concern. Isolating the other directories in their own volumes will be the strategy used so that their dynamic growth does not affect the root partition. Filling the root volume in a system is a very bad thing and should be avoided at all costs. With segregated partitions, we have margin of maneuver, like increasing one partition, reducing another, since the volume is not 100% occupied by the logical volumes (partitions).

Partitions may be increased later, but start with this minimum size, these numbers will be used for the initial installation of the system.

The volumes shall be initially divided as follows:

| Partition   | Size   | Description                                                                                            |
|-------------|--------|--------------------------------------------------------------------------------------------------------|
| **boot**    | 512 Mb | Boot loader files (ex: kernel, initrd). Single space residing outside the Logical Volume Manager (LVM) |
| **root**    | 2 Gb   | Operational System (/bin, /lib, /etc, /sbin)                                                           |
| **home**    | 2 Gb   | User directories.                                                                                      |
| **opt**     | 1 Gb   | Static application packages.                                                                           |
| **tmp**     | 1 Gb   | Temporary files.                                                                                       |
| **usr**     | 10 Gb  | Secondary hierarchy for shared user data whose access is restricted for read only.                     |
| **var**     | 10 Gb  | "Variable" files, such as logs, databases, web pages and e-mail files, container images, etc.          |
> **source:** http://refspecs.linuxfoundation.org/FHS_3.0/fhs-3.0.html)

#### Software
The installation of software packages that make up the base image are necessary to avoid repetition of work in the other VMs that will be created from it.

As we are creating an image using VirtualBox as our virtualization system an important software that should compose every image is VirtualBox Guest Additions, in addition to its dependencies.

The softwares to be installed will be the following:

| Software                       | Description                                                                                                     |
|--------------------------------|-----------------------------------------------------------------------------------------------------------------|
| **build-essential**            | This package contains an informational list of packages which are considered essential for building Debian packages.  This package also depends on the packages on that list, to make it easy to have the build-essential packages installed. |
| **module-assistant**           | The module-assistant tool (also known as m-a) helps users and maintainers with managing external Linux kernel modules packaged for Debian. It also contains some infrastructure to be used by the build-scripts in the accompanying modules-source packages in Debian. |
| **resolvconf**                 | Resolvconf is a framework for keeping up to date the system's information about name servers. It sets itself up as the intermediary between programs that supply this information (such as ifup and ifdown, DHCP clients, the PPP daemon and local name servers) and programs that use this information (such as DNS caches and resolver libraries). |
| **ntp**                        | NTP, the Network Time Protocol, is used to keep computer clocks accurate by synchronizing them over the Internet or a local network, or by following an accurate hardware receiver that interprets GPS, DCF-77, NIST or similar time signals. |
| **sudo**                       | Sudo is a program designed to allow a sysadmin to give limited root privileges to users and log root activity.  The basic philosophy is to give as few privileges as possible but still allow people to get their work done. |
| **cloud-init**                 | Cloud-init provides a framework and tool to configure and customize virtual machine instances for Infrastructure-as-a-Service (IaaS) clouds platforms. It can for example set a default locale and hostname, generate SSH private host keys, install SSH public keys for logging into a default account, set up ephemeral mount points, and run user-provided scripts. |
| **VirtualBox Guest Additions** | The VirtualBox Guest Additions consist of device drivers and system applications that optimize the operating system for better performance and usability. One of the usability features required in this guide is automated logons, which is why you need to install the Guest Additions in the virtual machine. |
> **source:** apt-cache show package-name

#### Installation
In the following videos you will be shown how to do a base installation for both Debian 9 Stretch and Ubuntu 18.04 LTS Server.

> **ISO install:** https://cdimage.debian.org/debian-cd/current/amd64/iso-dvd/debian-9.9.0-amd64-DVD-1.iso
[![Debian 9 Stretch base image VirtualBox](http://i3.ytimg.com/vi/mG8scaDoZog/hqdefault.jpg)](https://youtu.be/mG8scaDoZog)

> **ISO install:** http://cdimage.ubuntu.com/ubuntu/releases/18.04/release/ubuntu-18.04.2-server-amd64.iso
[![Debian 9 Stretch base image VirtualBox](http://i3.ytimg.com/vi/Zo82rXBEzco/hqdefault.jpg)](https://youtu.be/Zo82rXBEzco)

#### Or if you prefere download base image

##### Debian
```
$ cd ~/VirtualBox\ VMs/

$ wget https://www.dropbox.com/s/xcsk4matlzmjo2m/debian-base-image.tar.bz2?dl=0 -O - | tar xvjf -

$ vboxmanage registervm ~/VirtualBox\ VMs/debian-base-image/debian-base-image.vbox
```

##### Ubuntu
```
$ cd ~/VirtualBox\ VMs/

$ wget https://www.dropbox.com/s/hicmmy39gc3gog2/ubuntu-base-image.tar.bz2?dl=0 -O - | tar xvjf -

$ vboxmanage registervm ~/VirtualBox\ VMs/ubuntu-base-image/ubuntu-base-image.vbox
```