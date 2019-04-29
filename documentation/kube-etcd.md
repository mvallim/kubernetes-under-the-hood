## ETCD
*“**etcd** is a distributed key value store that provides a reliable way to store data across a cluster of machines. It’s open-source and available on GitHub. etcd gracefully handles leader elections during network partitions and will tolerate machine failure, including the leader.”*

### Failure Tolerance
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
<p align="center">
  <img src="images/kube-etcd.gif">
</p>
