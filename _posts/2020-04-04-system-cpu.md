---
layout: post
title: CPU架构
categories: java
tags: threadsafe jvm
---

```shell
# 查看CPU的架构
$ lscpu
Architecture:          x86_64
CPU op-mode(s):        32-bit, 64-bit
Byte Order:            Little Endian
CPU(s):                32
On-line CPU(s) list:   0-31
Thread(s) per core:    2
Core(s) per socket:    8
Socket(s):             2
NUMA node(s):          2
Vendor ID:             GenuineIntel
CPU family:            6
Model:                 79
Stepping:              1
CPU MHz:               2097.440
BogoMIPS:              4194.70
Virtualization:        VT-x
L1d cache:             32K
L1i cache:             32K
L2 cache:              256K
L3 cache:              20480K
NUMA node0 CPU(s):     0,2,4,6,8,10,12,14,16,18,20,22,24,26,28,30
NUMA node1 CPU(s):     1,3,5,7,9,11,13,15,17,19,21,23,25,27,29,31
```

## SMP架构

SMP（Symmetric Multiprocessing）对称多处理器。顾名思义, 在SMP中所有的处理器都是对等的, 它们通过总线连接共享同一块物理内存。

## NMUA架构

单核CPU -> FSB总线 -> 内存控制器(北桥) -> 内存1/内存2/.../内存N
多核CPU1/CPU2/.../CPUN -> FSB总线 -> 内存控制器(北桥) -> 内存1/内存2/.../内存N
刚开始核不多的时候，FSB总线勉强还可以支撑。但是随着CPU内核越来越多，所有的数据IO都通过一条FSB总线和内存交换数据，这条FSB就成为了整个计算机系统的瓶颈。

为了解决这个问题，CPU的设计者们引入了QPI总线，相应的CPU的结构就叫NMUA架构；

内存1/内存2 <- CPU1内存控制器 <-- QPI总线 --> CPU2内存控制器 -> 内存3/内存4

### NUMA陷阱

NUMA陷阱指的是引入QPI总线后，在计算机系统里可能会存在的一个坑。大致的意思就是如果你的机器打开了numa，那么你的内存即使在充足的情况下，也会使用磁盘上的swap，导致性能低下。原因就是NUMA为了高效，会仅仅只从你的当前node里分配内存，只要当前node里用光了（即使其它node还有），也仍然会启用硬盘swap。

```shell
# 查看服务器NUMA状态（机器有两个内存区域(zone)：node0和node1，分别有16个核心，各有32GB的内存）
$ numactl --hardware
available: 2 nodes (0-1)
node 0 cpus: 0 2 4 6 8 10 12 14 16 18 20 22 24 26 28 30
node 0 size: 32546 MB
node 0 free: 13991 MB
node 1 cpus: 1 3 5 7 9 11 13 15 17 19 21 23 25 27 29 31
node 1 size: 32768 MB
node 1 free: 14528 MB
node distances:
node   0   1 
  0:  10  21 
  1:  21  10 

# 查看内存区域(zone)内部的内存耗尽时的回收策略（机器的zone_reclaim_mode=1，内存区域内部的内存耗尽后，只会在本地节点回收内存）
# 0 关闭zone_reclaim模式，可以从其他zone或NUMA节点回收内存
# 1 打开zone_reclaim模式，这样内存回收只会发生在本地节点内
# 2 在本地回收内存时，可以将cache中的脏数据写回硬盘，以回收内存
# 4 在本地回收内存时，表示可以用Swap方式回收内存
$ cat /proc/sys/vm/zone_reclaim_mode
1

# 查看内存区域的内存使用情况
$ cat /proc/zoneinfo | grep 'Node \<[[:digit:]]\{1,2\}\>, zone   Normal' -A 1 --color
Node 0, zone   Normal
  pages free     3329247
--
Node 1, zone   Normal
  pages free     3725673
```

在zone_reclaim_mode为1的情况下，Redis是平均在两个node里申请节点的，并没有固定在某一个CPU里。
`如果不绑定亲和性的话，分配内存是当进程在哪个node上的CPU发起内存申请，就优先在哪个node里分配内存。`
之所以是平均分配在两个node里，是因为redis-server进程实验中经常会进入主动睡眠状态，醒来后可能CPU就换了。所以基本上，最后看起来内存是平均分配的。

```shell
# 查看上下文切换（CPU进行了500万次的上下文切换，用top命令看到cpu也是在node0和node1跳来跳去）
$ grep ctxt /proc/8356/status
voluntary_ctxt_switches:        5259503
nonvoluntary_ctxt_switches:     1449
```

```shell
# 绑定CPU和内存的亲和性
$ numactl --cpunodebind=0 --membind=0 ./redis-server ./redis.conf
```

```sql
-- 查看LSN的情况
$ show engine innodb status
---
LOG
---
Log sequence number 127847508936 -- 表示当前的LSN
Log flushed up to   127847419933 -- 表示刷新到重做日志文件的LSN
Last checkpoint at  127845797495 -- 表示刷新到磁盘的LSN
0 pending log writes, 0 pending chkp writes
167531559 log i/o's done, 102.19 log i/o's/second
```

Logsequencenumber和Logflushedupto的值在实际生产环境中有可能是不同的，因为在一个事务中从日志缓冲刷新到重做日志文件并不只是在事务提交时发生，每秒都会有从日志缓冲刷新到重做日志文件的动作。

恢复

InnoDB存储引擎在启动时不管上次数据库运行时是否正常关闭，都会尝试进行恢复操作。

## MySQL磁盘写入策略

`innodb_flush_log_at_trx_commit`和`sync_binlog`两个参数是控制MySQL磁盘写入策略以及数据安全性的关键参数。

### innodb_flush_log_at_trx_commit

* 参数说明：当重新安排并批量处理与提交相关的I/O操作时，可以控制磁盘的写入策略，严格遵守ACID合规性和高性能之间的平衡，该参数默认值为2
* 取值范围：0, 1, 2

0：日志缓存区将每隔一秒写到日志文件中，并且将日志文件的数据刷新到磁盘上。该模式下在事务提交时不会主动触发写入磁盘的操作。
1：每次事务提交时MySQL都会把日志缓存区的数据写入日志文件中，并且刷新到磁盘中，该模式为系统默认。
2：每次事务提交时MySQL都会把日志缓存区的数据写入日志文件中，但是并不会同时刷新到磁盘上。该模式下，MySQL会每秒执行一次刷新磁盘操作。

说明：
当设置为0，该模式速度最快，但不太安全，mysqld进程的崩溃会导致上一秒钟所有事务数据的丢失；
当设置为1，该模式是最安全的，但也是最慢的一种方式。在mysqld服务崩溃或者服务器主机宕机的情况下，日志缓存区只有可能丢失最多一个语句或者一个事务；
当设置为2，该模式速度较快，较取值为0情况下更安全，只有在操作系统崩溃或者系统断电的情况下，上一秒钟所有事务数据才可能丢失；

### sync_binlog

* 参数说明：同步binlog（MySQL持久化到硬盘，或依赖于操作系统）。
* 取值范围：0～4,294,967,295

sync_binlog=1 or N

默认情况下，并不是每次写入时都将binlog日志文件与磁盘同步。因此如果操作系统或服务器崩溃，有可能binlog中最后的语句丢失。

为了防止这种情况，你可以使用"sync_binlog"全局变量（1是最安全的值，但也是最慢的），使binlog在每N次binlog日志文件写入后与磁盘同步。

### 推荐配置组合

* innodb_flush_log_at_trx_commit = 1 && sync_binlog = 1，合数据安全性要求非常高，而且磁盘写入能力足够支持业务。
* innodb_flush_log_at_trx_commit = 1 && sync_binlog = 0，适合数据安全性要求高，磁盘写入能力支持业务不足，允许备库落后或无复制。
* innodb_flush_log_at_trx_commit = 2 && sync_binlog = `0/N(0<N<100)`，适合数据安全性要求低，允许丢失一点事务日志，允许复制延迟。
* innodb_flush_log_at_trx_commit = 0 && sync_binlog = 0，磁盘写能力有限，无复制或允许复制延迟较长。

说明：
"innodb_flush_log_at_trx_commit"和"sync_binlog"两个参数设置为1的时候，安全性最高，写入性能最差。在mysqld服务崩溃或者服务器主机宕机的情况下，日志缓存区只有可能丢失最多一个语句或者一个事务。但是会导致频繁的磁盘写入操作，因此该模式也是最慢的一种方式。当sync_binlog=N(N>1)，innodb_flush_log_at_trx_commit=2时，在当前模式下MySQL的写操作才能达到最高性能。
