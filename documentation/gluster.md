## Gluster

GlusterFS is a scalable network filesystem suitable for data-intensive tasks such as cloud storage and media streaming. GlusterFS is free and open source software and can utilize common off-the-shelf hardware.
> Reference: https://docs.gluster.org/en/latest/Administrator%20Guide/GlusterFS%20Introduction/

### Volume Types

#### Distributed

Distributed volumes distribute files across the bricks in the volume. You can use distributed volumes where the requirement is to scale storage and the redundancy is either not important or is provided by other hardware/software layers.

<p align="center">
  <img src="images/gluster-distributed.png">
</p>

#### Replicated

Replicated volumes replicate files across bricks in the volume. You can use replicated volumes in environments where high-availability and high-reliability are critical.

<p align="center">
  <img src="images/gluster-replicated.png">
</p>

#### Dispersed

Dispersed volumes are based on erasure codes, providing space-efficient protection against disk or server failures. It stores an encoded fragment of the original file to each brick in a way that only a subset of the fragments is needed to recover the original file (EC). The number of bricks that can be missing without losing access to data is configured by the administrator on volume creation time.

<p align="center">
  <img src="images/gluster-dispersed.png">
</p>

##### Erasure coding (EC)

It is a data protection and storage process through which a data object is separated into smaller components/fragments and each of those fragments is encoded with redundant data padding. EC transforms data object fragments into larger fragments and uses the primary data object identifier to recover each fragment.

Erasure coding is also known as **forward error correction** (FEC).

Erasure coding is primarily used in applications that have a low tolerance for data errors. This includes most data backup services and technologies including disk arrays, object-based cloud storage, archival storage and distributed data applications.

> Reference: https://en.wikipedia.org/wiki/Erasure_code

##### Overview

<p align="center">
  <img src="images/gluster-ec.gif">
</p>

