# etcd

*etcd is a distributed key value store that provides a reliable way to store data across a cluster of machines. It’s open-source and available on GitHub. etcd gracefully handles leader elections during network partitions and will tolerate machine failure, including the leader.*

> Reference: https://coreos.com/etcd/docs/latest/

It is a daemon that runs on all servers in a cluster, providing a dynamic configuration record and allowing multiple configuration data to be shared between cluster members in a simple way.

Because data is stored in a key-value form in **etcd**, it is distributed and replicated automatically (with a **leader** being automatically selected). All changes to the stored data are reflected throughout the whole cluster.

**etcd** also provides a discovery service, allowing “deployed” applications to advertise the services they make available to all cluster nodes.

Communication with **etcd** is done through API calls, using JSON over HTTP. The API can be used directly (via curl or wget for example), or indirectly through etcdctl.

> Reference: https://etcd.io/

## Failure Tolerance

It is recommended to have an odd number of members in a cluster. Having an odd cluster size doesn’t change the number needed for majority, but you gain a higher tolerance for failure by adding the extra member. You can see this in practice when comparing even and odd sized clusters

> Reference: https://coreos.com/etcd/docs/latest/v2/admin_guide.html

## Replication

In computer science, state machine replication or state machine approach is a general method for implementing a fault-tolerant service by replicating servers and coordinating client interactions with server replicas. The approach also provides a framework for understanding and designing replication management protocols.

> Reference: https://en.wikipedia.org/wiki/State_machine_replication

* **Active Replication**
  All nodes implement a finite state machine
  - They agree with each other (quorum) on the order of operations and perform them locally;
* **Passive Replication**
  A node is designated a the leader (see the animation below), which receives all writing commands
  - The leader node effectively performs quorum operations with most replicas;
  - The leader node is responsible for replicating state to the other replicas;

## Consensus (raft)

Raft is a consensus algorithm that is designed to be easy to understand. It’s equivalent to Paxos in fault-tolerance and performance. The difference is that it’s decomposed into relatively independent subproblems, and it cleanly addresses all major pieces needed for practical systems. We hope Raft will make consensus available to a wider audience, and that this wider audience will be able to develop a variety of higher quality consensus-based systems than are available today.

> Reference: https://raft.github.io/

### What are distributed consensus algorithms?

* Algorithms that allow a group of processes to agree on a value;
* It allows coordinating distributed processes;
* They arise in the context of replicated state machines;
* Such algorithms play a crucial role in the construction of large scale and reliable distributed systems;

### A little analogy for better understanding this concept

> Once upon a time, there was a kingdom, the **Cluster Land**, ruled by a king. This king was very democratic and was supported by a group composed of 9 very wise, loyal, counselors.

> Every time a request was brought to the king by his subjects, the king would first consult with his counselors before deciding whether or not the request would be attended. If the majority of the counselors voted positively, the request would be attended. Otherwise, it would be declined.

This is a very basic analogy of how a transaction is committed to the logs in the Raft algorithm. All requests are handled by the leader (the King) and they are only committed after the majority of the counselors (the other nodes in the cluster) accept it.

> One day, when fighting a terrible dragon, the king died. Without waiting any mourning period, the counselors decided one of them should be chosen as the new ruling king. 2 (let’s call them counselors 5 and 7) out of the 9 counselors applied to be the new king. After a quick election, 4 counselors voted for counselor 5, while 3 of them voted for counselor 7. Now counselor 5 was the new king and started following the same politics as the previous ruler.

This roughly illustrates how the leader election happens in the Raft algorithm.

> After some time, unsatisfied with the way the new ruler has been governing the kingdom, some of the counselors start a rebellion that ends up splitting the king into two kingdoms: the **Cluster Land of the North** — ruled by counselor 5 — and the **Cluster Land of the South** — ruled by counselor 7 — each with its own king and its own counselors. People now live in one of these kingdoms and always direct their requests to their respective king. Even though the kingdoms are now separate, they are still governed in the same way (requests are directed to the kings who consult with their respective counselors).

> Years later, the two kings come to an agreement and decide to re-unit the kingdoms. Cluster Land is a single kingdom again, which is once again ruled by counselor 5. Unfortunately, conflicting laws were created on each kingdom during the period they were split. To solve this issue, the counselors agree that every law conflict will be solved by following the respective law that was promulgated more recently.

This part of the story illustrates a scenario of network partitioning, for example. In this scenario, the clusters are split and each new cluster now has its own leader and nodes. Conflicting requests may be handled by the different clusters, at different times and, when the clusters are merged back together, there needs to be a way of solving conflicting values. One of the things used in Raft to handle this are **Terms**.

(Story credits: [Ivam Luz](https://github.com/ivamluz))

### When to use?

* When it is necessary for processes to share a consistent, atomic, and ordered view of a series of operations/events;
  - High Availability (Fault Tolerance);
  - Performance (distribute load among thousands of clients);

## How does etcd fit inside the Kubernetes Cluster?

**etcd** the stores settings, state and metadata of **Kubernetes**. Because **Kubernetes** is a distributed system, it makes a lot of sense to use a distributed database. **etcd**, as already explained, is a distributed database with high availability and scalability.

*"An ideal wedding for an ideal solution in the **Cluster Land**."*