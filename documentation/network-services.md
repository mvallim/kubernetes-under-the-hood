## Network Services

### DNS
An Internet resource, for example a Web site, can be identified in two ways: by its domain name, for example, "kubernetes.io" or by the IP address of the hosts that host it (for example, 45.54.44.102 is the IP associated with the kubernetes.io domain). IP addresses are used by the network layer to determine the physical and virtual location of the equipment. Domain names, however, are more mnemonic for the user and business. You then need a mechanism to resolve a domain name to an IP address. This is the main function of DNS.

Occasionally, it is assumed that DNS serves only the purpose of mapping Internet host names to data and map addresses to host names. However, DNS can store a wide variety of data type, for almost any purpose.

### DHCP
The DHCP, Dynamic Host Configuration Protocol (DHCP), is a TCP / IP service protocol that provides dynamic configuration of terminals, granting host IP addresses, subnet mask, default gateway ), IP number of one or more DNS servers, DNS search suffixes, and IP number of one or more WINS servers. This protocol is the successor to BOOTP which, although simpler, has become limited to current requirements. DHCP came standard by October 1993. RFC 2131 (1997) contains the most current specifications. The last standard for the specification of DHCP over IPv6 (DHCPv6) was published as RFC 3315 (2003).

### Gateway
Gateways, also called protocol converters, can operate on any network layer. The activities of a gateway are more complex than those of the router or switch, since they communicate using more than one protocol.

The computers of Internet users and the computers that serve pages for users are network nodes, since the nodes that connect the networks between them are gateways. For example, computers that control traffic between enterprise networks or computers used by Internet service providers to connect users to the Internet are gateway nodes.

In the network for a company, a server computer that acts as a gateway node is often also acting as a proxy server and firewall server. A gateway is often associated with a router, which knows where to direct a particular packet of data that is received at the gateway and to switch it, which provides the gateway's actual input and output path to a particular receptacle.

### NAT
In computer networks, Network Address Translation (NAT), also known as masquerading, is a technique that consists of rewriting, using a hash table, the source IP addresses of a packet passing through a router or firewall in a manner that a computer on an internal network has access to the outside or World Wide Web (public network).