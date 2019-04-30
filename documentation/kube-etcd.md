## ETCD
*“**etcd** is a distributed key value store that provides a reliable way to store data across a cluster of machines. It’s open-source and available on GitHub. etcd gracefully handles leader elections during network partitions and will tolerate machine failure, including the leader.”*
> Reference: https://coreos.com/etcd/docs/latest/

### Failure Tolerance
*"It is recommended to have an odd number of members in a cluster. Having an odd cluster size doesn't change the number needed for majority, but you gain a higher tolerance for failure by adding the extra member. You can see this in practice when comparing even and odd sized clusters"*
> Reference: https://coreos.com/etcd/docs/latest/v2/admin_guide.html

| CLUSTER SIZE<br>N | FAILURE TOLERANCE<br>T = (N-1) / 2 | MAJORITY<br>M = (N/2) + 1 |
|-------------------|------------------------------------|---------------------------|
| 1                 | **0**                              | 1                         |
| 2                 | **0**                              | 2                         |
| 3                 | **1**                              | 2                         |
| 4                 | **1**                              | 3                         |
| 5                 | **2**                              | 3                         |
| 6                 | **2**                              | 4                         |
| 7                 | **3**                              | 4                         |
| 8                 | **3**                              | 5                         |
| 9                 | **4**                              | 5                         |
| 10                | **4**                              | 5                         |

### Consensus (raft)
*"Raft is a consensus algorithm that is designed to be easy to understand. It's equivalent to Paxos in fault-tolerance and performance. The difference is that it's decomposed into relatively independent subproblems, and it cleanly addresses all major pieces needed for practical systems. We hope Raft will make consensus available to a wider audience, and that this wider audience will be able to develop a variety of higher quality consensus-based systems than are available today."*
> Reference: https://raft.github.io/

<p align="center">
  <img src="images/kube-etcd.gif">
</p>
