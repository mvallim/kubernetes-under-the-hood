## Kubernetes
*"Kubernetes (κυβερνήτης, Greek for "governor", "helmsman" or "captain") was founded by Joe Beda, Brendan Burns and Craig McLuckie, who were quickly joined by other Google engineers including Brian Grant and Tim Hockin, and was first announced by Google in mid-2014. Its development and design are heavily influenced by Google's Borg system, and many of the top contributors to the project previously worked on Borg. The original codename for Kubernetes within Google was Project Seven of Nine, a reference to a Star Trek character that is a "friendlier" Borg. The seven spokes on the wheel of the Kubernetes logo are a reference to that codename. The original Borg project was written entirely in C++, but the rewritten Kubernetes system is implemented in Go."*

*"Kubernetes v1.0 was released on July 21, 2015. Along with the Kubernetes v1.0 release, Google partnered with the Linux Foundation to form the Cloud Native Computing Foundation (CNCF) and offered Kubernetes as a seed technology. On March 6, 2018, Kubernetes Project reached ninth place in commits at GitHub, and second place in authors and issues to the Linux kernel."*
> Reference: https://kubernetes.io/docs/concepts/overview/what-is-kubernetes/

### Objects

#### Pods
Lorem ipsum dolor sit amet, consectetur adipiscing elit. In tempor risus id diam dignissim facilisis. Quisque tempor, justo in blandit volutpat, magna mi aliquet mi, ac consectetur urna libero sit amet lacus. Nulla sed vestibulum ex, quis rutrum libero. Ut vitae quam a nisl mollis suscipit auctor ut dolor. Praesent pharetra viverra nunc at rhoncus. Quisque consequat dictum congue. Curabitur eu felis sed massa ultricies ullamcorper. Vivamus vel laoreet tellus. Nulla a vulputate diam, iaculis ultrices ex. Nam convallis eu neque vitae molestie. Sed in arcu ultrices, aliquet lectus et, commodo nunc. Aliquam congue purus a dolor consequat ultrices. Vestibulum id lectus porttitor urna blandit consectetur in sit amet lacus.

#### Service
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Nullam elementum rhoncus ligula id dignissim. Maecenas nec dolor sed tortor rutrum gravida id ut ipsum. Aliquam porttitor neque non nunc ultrices, tincidunt porta quam dapibus. In hac habitasse platea dictumst. Nulla vulputate justo id massa vulputate tincidunt sit amet et mauris. Maecenas nisi tortor, luctus nec fringilla ac, facilisis ac leo. Sed eu nibh sollicitudin, sodales nulla nec, feugiat lectus. Aliquam congue turpis sed enim efficitur, porttitor condimentum lorem elementum. Vivamus sodales tristique nibh, et vulputate arcu gravida sed. Sed in lorem vel leo hendrerit vehicula vel vel quam. Praesent auctor purus ligula, at laoreet arcu feugiat vitae. Duis id porta quam.

#### Volumes
* **Filesystem**
In Kubernetes, each container can read and write in its own filesystem.
But the data written into this filesystem is destroyed when the container is restarted or removed.

* **Volume**
Kubernetes has volumes. Volumes that are in a POD will exist as long as the POD exists. Volumes can be shared among the same POD containers. When a POD is restarted or removed the volume is destroyed.

* **Persistent Volume**
The Kubernetes has persistent volumes. Persistent volumes are long-term stores within the Kubernetes cluster. Persistent volumes go beyond containers, PODs, and nodes, they exist as long as the Kubernetes cluster exists. A POD claims the use of a persistent volume for reading or writing or for reading and writing.

| Type              | How long?          |
|-------------------|--------------------|
| Filesystem        | Container lifetime |
| Volume            | Pod lifetime       |
| Persistent Volume | Cluster lifetime   |

#### Namespaces
Lorem ipsum dolor sit amet, consectetur adipiscing elit. Donec a vulputate lacus. Quisque eget accumsan massa, quis tincidunt magna. Proin id scelerisque velit. Mauris sed euismod erat, quis aliquam nisl. Donec massa neque, mollis hendrerit ligula quis, gravida lacinia sem. Quisque id semper dui, quis facilisis tellus. Cras interdum ligula non tellus molestie scelerisque. Vestibulum in hendrerit felis, auctor molestie quam. Orci varius natoque penatibus et magnis dis parturient montes, nascetur ridiculus mus. Fusce luctus leo nisi, at fringilla felis viverra tristique. Quisque eget dapibus justo. Aenean mollis sapien ut lorem pretium tempus. Praesent malesuada eros vel facilisis laoreet. Praesent facilisis posuere nunc ut pulvinar. In luctus ipsum eget leo mattis, quis molestie erat bibendum. Proin eros metus, cursus a vulputate ut, semper ut elit.
