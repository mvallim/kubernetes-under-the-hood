# How to setup the Debian Linux image from scratch

This document shows how to create a Debian image from scratch to run on Cloud environments (EC2, GCE, Azure, OpenStack, QEMU and VirtualBox).

<p align="center">
   <img src="images/linux-image.png">
</p>

## Prerequisites (GNU/Linux Debian/Ubuntu)

* Install the applications needed to build the environment:

   ```bash
   sudo apt-get install debootstrap
   ```

* Create a folder to store the image:

   ```bash
   mkdir $HOME/debian-image-from-scratch
   ```

## Create the [loop device](https://en.wikipedia.org/wiki/Loop_device)

1. Create an empty virtual hard drive file (`30Gb`):

   ```bash
   dd \
     if=/dev/zero \
     of=~/debian-image-from-scratch/debian-image.raw \
     bs=1 \
     count=0 \
     seek=32212254720 \
     status=progress
   ```

   Where:
   * **`if`**: read from FILE instead of stdin
   * **`of`**: write to FILE instead of stdout
   * **`bs`**: read and write up to BYTES bytes at a time (default: 512); overrides ibs and obs
   * **`count`**: copy only N input blocks
   * **`seek`**: skip N obs-sized blocks at start of output
   * **`status`**: The LEVEL of information to print to stderr;

   > More details: man 1 dd

2. Create partitions on the file:

   ```bash
   sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/' << EOF | sudo fdisk ~/debian-image-from-scratch/debian-image.raw
   o # clear the in memory partition table
   n # new partition
   p # primary partition
   1 # partition number 1 
       # default - start at beginning of disk
   +512M # 512 MB boot parttion
   n # new partition
   p # primary partition
   2 # partion number 2
       # default, start immediately after preceding partition
       # default, extend partition to end of disk
   a # make a partition bootable
   1 # bootable partition is partition 1 -- /dev/loop0p1
   p # print the in-memory partition table
   w # write the partition table
   q # and we're done
   EOF
   ```

   This command is going to call `fdisk` to partition the loop device at `~/debian-image-from-scratch/debian-image.raw`. 

   `sed -e 's/\s*\([\+0-9a-zA-Z]*\).*/\1/'` is responsible for parsing the subsequent lines, keeping only the parameters at the beginning. Thus, `o # clear the in memory partition table` would be replaced with `o`, telling fdisk to clear the in-memory partition table; `n # new partition` would be replaced with `n`, telling fdisk a new partition should be created and so on and so forth.

3. Start the loop device:

   ```bash
   sudo losetup -fP ~/debian-image-from-scratch/debian-image.raw
   ```

   3.1. Check the status of the loop device:

   ```bash
   sudo losetup -a
   ```

   Expected output:

   ```console
   /dev/loop0: [64775]:26084892 (/home/mvallim/debian-image-from-scratch/debian-image.raw)
   ```

4. Check the partitions on the loop device:

   ```bash
   sudo fdisk -l /dev/loop0
   ```

   Expected output:

   ```console
   Disk /dev/loop0: 30 GiB, 32212254720 bytes, 62914560 sectors
   Units: sectors of 1 * 512 = 512 bytes
   Sector size (logical/physical): 512 bytes / 512 bytes
   I/O size (minimum/optimal): 512 bytes / 512 bytes
   Disklabel type: dos
   Disk identifier: 0xf4e11bd3

   Device       Boot   Start      End  Sectors  Size Id Type
   /dev/loop0p1 *       2048  1050623  1048576  512M 83 Linux
   /dev/loop0p2      1050624 62914559 61863936 29.5G 83 Linux
   ```

## Format the partitions in the loop device

   1. Format the `loop0p1` device (`/boot`):

      ```bash
      sudo mkfs.ext4 /dev/loop0p1
      ```

      Expected output:

      ```console
      mke2fs 1.44.5 (15-Dec-2018)
      Discarding device blocks: done
      Creating filesystem with 131072 4k blocks and 32768 inodes
      Filesystem UUID: 4d426158-5c62-4b8c-8dcb-52c47e83df3e
      Superblock backups stored on blocks:
            32768, 98304

      Allocating group tables: done
      Writing inode tables: done
      Creating journal (4096 blocks): done
      Writing superblocks and filesystem accounting information: done
      ```

   2. Format the `loop0p2` device (`/`):

      ```bash
      sudo mkfs.ext4 /dev/loop0p2
      ```

      Expected output:

      ```console
      mke2fs 1.44.5 (15-Dec-2018)
      Discarding device blocks: done
      Creating filesystem with 7732992 4k blocks and 1933312 inodes
      Filesystem UUID: 88086414-602f-4099-a112-c94a1c6a13f5
      Superblock backups stored on blocks:
            32768, 98304, 163840, 229376, 294912, 819200, 884736, 1605632, 2654208,
            4096000

      Allocating group tables: done
      Writing inode tables: done
      Creating journal (32768 blocks): done
      Writing superblocks and filesystem accounting information: done
      ```

## Mount the loop devices

1. Create the `chroot` directory:

   ```bash
   mkdir ~/debian-image-from-scratch/chroot
   ```

2. Mount the `root` partition:

   ```bash
   sudo mount /dev/loop0p2 ~/debian-image-from-scratch/chroot/
   ```

3. Create and mount the `boot` partition:

   3.1. Create the directory:

   ```bash
   sudo mkdir ~/debian-image-from-scratch/chroot/boot
   ```

   3.2. Mount the `boot` partition:

   ```bash
   sudo mount /dev/loop0p1 ~/debian-image-from-scratch/chroot/boot
   ```

## Bootstrap and configure Debian

* Run `debootstrap`

  > **debootstrap** is used to create a Debian base system from scratch, without requiring the availability of **dpkg** or **apt**. It does this by downloading .deb files from a mirror site, and carefully unpacking them into a directory which can eventually be **chrooted** into.

  ```bash
  sudo debootstrap \
     --arch=amd64 \
     --variant=minbase \
     --components "main" \
     --include "ca-certificates,cron,iptables,isc-dhcp-client,libnss-myhostname,ntp,ntpdate,rsyslog,ssh,sudo,dialog,whiptail,man-db,curl,dosfstools,e2fsck-static" \
     stretch \
     $HOME/debian-image-from-scratch/chroot \
     http://deb.debian.org/debian/
  ```

* Configure external mount points

  As we will be updating and installing packages (`grub` among them), these mount points are necessary inside the chroot environment, so we are able to complete the installation without errors.

  ```bash
  sudo mount --bind /dev $HOME/debian-image-from-scratch/chroot/dev
  
  sudo mount --bind /run $HOME/debian-image-from-scratch/chroot/run
  ```

## Define the chroot environment

*A chroot on Unix operating systems is an operation that changes the apparent root directory for the current running process and its children. A program that is run in such a modified environment cannot name (and therefore normally cannot access) files outside the designated directory tree. The term "chroot" may refer to the chroot system call or the chroot wrapper program. The modified environment is called a chroot jail.*

> Reference: https://en.wikipedia.org/wiki/Chroot

1. Access the chroot environment:

   ```bash
   sudo chroot $HOME/debian-image-from-scratch/chroot
   ```

2. Configure the mount points, home and locale:

   These mount points are necessary inside the chroot environment, so we are able to complete the installation without errors.

   ```bash
   mount none -t proc /proc

   mount none -t sysfs /sys

   mount none -t devpts /dev/pts

   export HOME=/root

   export LC_ALL=C
   ```

3. Set a custom hostname:

   ```bash
   echo "debian-image" > /etc/hostname
   ```

4. Configure `apt sources.list`:

   ```bash
   cat <<EOF > /etc/apt/sources.list
   deb http://deb.debian.org/debian/ stretch main contrib non-free
   deb-src http://deb.debian.org/debian/ stretch main contrib non-free

   deb http://deb.debian.org/debian/ stretch-updates main contrib non-free
   deb-src http://deb.debian.org/debian/ stretch-updates main contrib non-free

   deb http://deb.debian.org/debian-security stretch/updates main
   deb-src http://deb.debian.org/debian-security stretch/updates main
   EOF
   ```

5. Configure `fstab`:

   ```bash
   cat <<EOF > /etc/fstab
   # /etc/fstab: static file system information.
   #
   # Use 'blkid' to print the universally unique identifier for a
   # device; this may be used with UUID= as a more robust way to name devices
   # that works even if disks are added and removed. See fstab(5).
   #
   # <file system>         <mount point>   <type>  <options>                       <dump>  <pass>
   /dev/sda2               /               ext4    errors=remount-ro               0       1
   /dev/sda1               /boot           ext4    defaults                        0       2
   EOF
   ```

6. Update the `apt` packages indexes:

   ```bash
   apt-get update
   ```

7. Install `systemd`:

   > **systemd** is a system and service manager for Linux. It provides aggressive parallelization capabilities, uses socket and D-Bus activation for starting services, offers on-demand starting of daemons, keeps track of processes using Linux control groups, maintains mount and automount points and implements an elaborate transactional dependency-based service control logic.

   ```bash
   apt-get install -y systemd-sysv
   ```

8. Configure `machine-id` and `divert`:

   > The `/etc/machine-id` file contains the unique machine ID of the local system that is set during installation or boot. The machine ID is a single newline-terminated, hexadecimal, 32-character, lowercase ID. When decoded from hexadecimal, this corresponds to a 16-byte/128-bit value. This ID may not be all zeros.

   ```bash
   dbus-uuidgen > /etc/machine-id

   ln -fs /etc/machine-id /var/lib/dbus/machine-id
   ```

   > **dpkg-divert** is the utility used to set up and update the list of diversions. File diversions are a way of forcing dpkg not to install a file into its location, but to a diverted location.

   ```bash
   dpkg-divert --local --rename --add /sbin/initctl

   ln -s /bin/true /sbin/initctl
   ```

9. Install the packages needed for the system:

   ```bash
   apt-get install -y \
       os-prober \
       ifupdown \
       network-manager \
       resolvconf \
       locales \
       build-essential \
       module-assistant \
       cloud-init \
       grub-pc \
       grub2 \
       linux-image-amd64 \
       linux-headers-amd64
   ```

   The dialogs below will appear as a result of the packages that will be installed from the previous step.

   9.1. Configure grub.
      <p align="center">
        <img src="images/grub-configure-01.png">
      </p>

   9.2. Don’t select any option.
      <p align="center">
        <img src="images/grub-configure-02.png">
      </p>

   9.3. Only confirm with “Yes”.
      <p align="center">
        <img src="images/grub-configure-03.png">
      </p>

10. Configure the network interfaces:

    ```bash
    cat <<EOF > /etc/network/interfaces
    # This file describes the network interfaces available on your system
    # and how to activate them. For more information, see interfaces(5).

    source /etc/network/interfaces.d/*

    # The loopback network interface
    auto lo
    iface lo inet loopback
    EOF
    ```

11. Reconfigure the packages:

    11.1. Generate the locales:

       ```bash
       dpkg-reconfigure locales
       ```

       11.1.1. *Select the locales you want to be generated*:
          <p align="center">
            <img src="images/locales-select.png">
          </p>

       11.1.2. *Select the default locale*:
          <p align="center">
            <img src="images/locales-default.png">
          </p>   

    11.2. Reconfigure `resolvconf`:

       ```bash
       dpkg-reconfigure resolvconf
       ```

       11.2.1. Confirm the changes:
          <p align="center">
            <img src="images/resolvconf-confirm-01.png">
          </p>
          <p align="center">
            <img src="images/resolvconf-confirm-02.png">
          </p>

    11.3. Configure `network-manager`:

       ```bash
       cat <<EOF > /etc/NetworkManager/NetworkManager.conf
       [main]
       rc-manager=resolvconf
       plugins=ifupdown,keyfile
       dns=default

       [ifupdown]
       managed=false
       EOF
       ```

    11.4. Reconfigure `network-manager`:

       ```bash
       dpkg-reconfigure network-manager
       ```

12. Install and configure `grub`:

    12.1. Install `grub`:

       ```bash
       grub-install /dev/loop0
       ```

       Expected output

       ```console
       Installing for i386-pc platform.
       Installation finished. No error reported.
       ```

    12.2. Update `grub` configuration:

       ```bash
       update-grub
       ```

       Expected output

       ```console
       Generating grub configuration file ...
       Found linux image: /boot/vmlinuz-4.9.0-11-amd64
       Found initrd image: /boot/initrd.img-4.9.0-11-amd64
       Adding boot menu entry for EFI firmware configuration
       done
       ```

## VirtualBox

If you plan to use this image in **VirtualBox**, install [**VirtualBox Guest Additions**](https://www.virtualbox.org/manual/ch04.html)

   1. Download VirtualBox Guest Additions:

       ```bash
       curl --progress-bar https://download.virtualbox.org/virtualbox/6.0.22/VBoxGuestAdditions_6.0.22.iso -o VBoxGuestAdditions_6.0.22.iso
       ```

   2. Mount the ISO file:

       ```bash
       mount -o loop VBoxGuestAdditions_6.0.22.iso /mnt
       ```

   3. Install VirtualBox:

       ```bash
       /mnt/VBoxLinuxAdditions.run
       ```

       Expected output

       ```console
       Verifying archive integrity... All good.
       Uncompressing VirtualBox 6.0.22 Guest Additions for Linux........
       VirtualBox Guest Additions installer
       Copying additional installer modules ...
       Installing additional modules ...
       depmod: ERROR: could not open directory /lib/modules/4.19.0-6-amd64: No such file or directory
       depmod: FATAL: could not search modules: No such file or directory
       VirtualBox Guest Additions: Starting.
       VirtualBox Guest Additions: Building the VirtualBox Guest Additions kernel
       modules.  This may take a while.
       VirtualBox Guest Additions: To build modules for other installed kernels, run
       VirtualBox Guest Additions:   /sbin/rcvboxadd quicksetup <version>
       VirtualBox Guest Additions: or
       VirtualBox Guest Additions:   /sbin/rcvboxadd quicksetup all
       VirtualBox Guest Additions: Kernel headers not found for target kernel
       4.19.0-6-amd64. Please install them and execute
         /sbin/rcvboxadd setup
       modprobe vboxguest failed
       The log file /var/log/vboxadd-setup.log may contain further information.
       Running in chroot, ignoring request.
       ```

   4. Generate modules inside `chroot` environment:

       ```bash
       ls -al /lib/modules
       ```

       Expected output

       ```console
       total 12
       drwxr-xr-x  3 root root 4096 Feb  2 23:36 .
       drwxr-xr-x 14 root root 4096 Feb  2 23:36 ..
       drwxr-xr-x  3 root root 4096 Feb  2 23:36 4.9.0-11-amd64
       ```

       Refer to the file name listed. In this case, `4.9.0-11-amd64`:

       ```bash
       rcvboxadd quicksetup 4.9.0-11-amd64
       ```

       Expected output

       ```console
       VirtualBox Guest Additions: Building the modules for kernel 4.9.0-11-amd64.
       update-initramfs: Generating /boot/initrd.img-4.9.0-11-amd64
       ```

   5. Umount and remove the ISO file:

       ```bash
       umount /mnt

       rm -rf VBoxGuestAdditions_6.0.22.iso
       ```

   6. Fix `vboxadd-service`

       ```bash
       sed -i -e 's/ systemd-timesyncd.service//g' /lib/systemd/system/vboxadd-service.service
       ```

      > As we are using ntpd, we remove the `systemd-timesyncd.service` from the `vboxadd-service.service` declaration.

## Clean up the chroot environment

   1. If you installed software, be sure to run:

       ```bash
       truncate -s 0 /etc/machine-id
       ```

   2. Remove the diversion:

       ```bash
       rm /sbin/initctl

       dpkg-divert --rename --remove /sbin/initctl
       ```

   3. Clean up:

       ```bash
       apt-get clean

       rm -rf /tmp/* ~/.bash_history

       umount /proc

       umount /sys

       umount /dev/pts

       export HISTSIZE=0

       exit
       ```

## Unbind mount points

```bash
sudo umount $HOME/debian-image-from-scratch/chroot/dev

sudo umount $HOME/debian-image-from-scratch/chroot/run
```

## Umount loop partitions

```bash
sudo umount $HOME/debian-image-from-scratch/chroot/boot

sudo umount $HOME/debian-image-from-scratch/chroot
```

## Check disks integrity

```bash
sudo fsck.ext4 /dev/loop0p1
```

Expected output:

```console
e2fsck 1.44.5 (15-Dec-2018)
/dev/loop0p1: clean, 337/32768 files, 14874/131072 blocks
```

```bash
sudo fsck.ext4 /dev/loop0p2
```

Expected output:

```console
e2fsck 1.44.5 (15-Dec-2018)
/dev/loop0p2: clean, 47759/1933312 files, 422742/7732992 blocks
```

## Detach all associated loop devices

```bash
sudo losetup -D
```

## Create the VirtualBox base image 

**Note:** **Virtualbox** should be properly installed on your local machine before you proceed.

1. Add your user to `vboxusers` group:

   ```bash
   sudo usermod -a -G vboxusers $USER
   ```

2. Create the VM:

   ```bash
   vboxmanage createvm --name debian-base-image --ostype Debian_64 --register
   ```

   Expected output:

   ```console
   Virtual machine 'debian-base-image' is created and registered.
   UUID: 3f925b8a-8044-4673-978b-dee6254b328f
   Settings file: '/home/mvallim/VirtualBox VMs/debian-base-image/debian-base-image.vbox'
   ```

3. Configure the VM "hardware" (make sure to run each command individually):

   ```bash
   vboxmanage modifyvm debian-base-image --memory 512 --ioapic on
   
   vboxmanage modifyvm debian-base-image --audio none
   
   vboxmanage modifyvm debian-base-image --usbcardreader off
   
   vboxmanage modifyvm debian-base-image --keyboard ps2 --mouse ps2
   
   vboxmanage modifyvm debian-base-image --graphicscontroller vboxsvga --vram 33
   
   vboxmanage modifyvm debian-base-image --nic1 nat
   
   vboxmanage modifyvm debian-base-image --rtcuseutc on
   
   vboxmanage storagectl debian-base-image --name "IDE" --add ide --controller PIIX4
   
   vboxmanage storagectl debian-base-image --name "SATA" --add sata --controller IntelAHCI --portcount 1
   
   vboxmanage storageattach debian-base-image --storagectl "IDE" --port 0 --device 0 --type dvddrive --medium emptydrive
   ```

4. Prepare the raw disk image to use on VirtualBox VMs:

   ```bash
   vboxmanage convertfromraw ~/debian-image-from-scratch/debian-image.raw "$HOME/VirtualBox VMs/debian-base-image/debian-base-image.vdi"
   ```

   Expected output:

   ```console
   Converting from raw image file="/home/mvallim/debian-image-from-scratch/debian-image.raw" to file="/home/mvallim/VirtualBox VMs/debian-base-image/debian-base-image.vdi"...
   Creating dynamic image with size 32212254720 bytes (30720MB)...
   ```

5. Attach disk to `debian-base-image` VM:

   ```bash
   vboxmanage storageattach debian-base-image --storagectl "SATA" --port 0 --device 0 --type hdd --medium "$HOME/VirtualBox VMs/debian-base-image/debian-base-image.vdi"
   ```

6. Clean up

   ```bash
   rm -rf $HOME/debian-image-from-scratch
   ```
