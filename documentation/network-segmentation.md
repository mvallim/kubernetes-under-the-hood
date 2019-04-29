## Network segmentation

Network segmentation in a computer network is a practice of separating computer networks into subnets into network segments. The advantages of this practice is in improving safety performance.

### Benefits

* **Traffic reduction**
    - Causes network traffic to be isolated to each network segment, which means that each network segment has its own traffic volume not influencing the entire network.
* **Safety**
    - Broadcast is restricted only to that network segment and not the entire network
    - The resources present in a network segment may be isolated from other networks or restricted from one subnet to another.
    - Common attacks are restricted to each subnet, not the entire network. In this way it is important to segment the network by type of resources (database, nfs, web)
* **Containment of problems**
    - Any network problem in one subnet is restricted to that subnet without affecting the entire network
* **Accesses**
    - Limitation of access to each of the subnets, as well as the form with one `a` subnet can access the other subnet `b`

### Overview

#### Net and Subnets
| Name          | Range          |
|---------------|----------------|
| CIDR          | 192.168.0.0/16 |
| POD CIDR      | 10.244.0.0/16  |
| Subnet - mast | 192.168.1.0/24 |
| Subnet - node | 192.168.2.0/24 |
| Subnet - glus | 192.168.3.0/24 |
| Subnet - dmz  | 192.168.4.0/24 |

#### DHCP
| Name        | Range                        |
|-------------|------------------------------|
| DHCP - mast | 192.168.1.50 - 192.168.1.200 |
| DHCP - node | 192.168.2.50 - 192.168.2.200 |
| DHCP - glus | 192.168.2.50 - 192.168.2.200 |
| DHCP - dmz  | 192.168.4.50 - 192.168.4.200 |

#### Gateways
| Name               | Address       |
|--------------------|---------------|
| DNS/Gateway - mast | 192.168.1.254 |
| DNS/Gateway - node | 192.168.2.254 |
| DNS/Gateway - glus | 192.168.3.254 |
| DNS/Gateway - dmz  | 192.168.4.254 |

#### Virtual IP
| Name               | Address      |
|--------------------|--------------|
| Control Plane      | 192.168.4.20 |

#### LoadBalancer
| Name               | Range                       |
|--------------------|-----------------------------|
| MetalLB            | 192.168.2.10 - 192.168.2.49 |

#### Blueprint
<p align="center">
  <img src="images/networking-diagram.png">
</p>