---
layout: post
title: MySQL 事务
categories: database
tags: mysql transaction
---

## 事务属性

`原子性（atomicity）`

一个事务必须被视为一个不可分割的最小工作单元，整个事务中的所有操作必须全部执行，不允许只执行其中的一部分操作；

`一致性（consistency）`

一个事务中的所有操作要么全部执行成功，要么全部执行失败；

`隔离性（isolation）`

一个事务所做的修改在最终提交以前，对其他事务是不可见的；

`持久性（durability）`

一旦事务提交，则其所做的修改就会持久化保存到磁盘中，此时即使系统崩溃，修改的数据也不会丢失；

---

## 隔离级别

InnoDB存储引擎默认的事务隔离级别是`可重复读 REPEATABLE RAED`。

`读未提交 READ UNCOMMITTED`

* 说明：一个事务中的修改，即使没有提交，对其他事务也都是可见的；
* 问题：存在`脏读 Dirty Reads`问题，即A事务中的操作读取了B事务中尚未提交的修改；

`读已提交 READ COMMITTED`

* 说明：一个事务中的操作只读取其他事务已提交的修改；
* 问题：存在`不可重复读 Non-Repeatable Reads`问题，即A事务中两次重复查询同一行数据的操作得到了不同的结果，因为在两次查询之间，B事务修改或删除了这一行数据并且提交了事务；

`可重复读 REPEATABLE READ`

* 说明：A事务中两次重复查询同一行数据的操作得到了不同的结果，因为在两次查询之间，B事务修改或删除了这一行数据并且提交了事务；
* 问题：存在`幻读 Phantom Reads`问题，幻读是A事务中重复查询相同条件范围内的数据，B事务在这个范围内插入了一条原先不存在的新数据，导致A事务中再次读取该范围内的数据时，将会产生幻行。

`可串行化 SERIALIZABLE`

* 说明：所有事务串行执行；
* 问题：不支持并发；

>疑问🤔️：为什么默认的事务隔离级别是可重复读 REPEATABLE RAED？

Mysql在5.0版本以前，binlog只支持STATEMENT格式，在`读已提交(Read Commited)`这个隔离级别下：

* 事务A：在表test中删除id=2的数据`delete from test where id < 2`；
* 事务B：在表test中插入id=2的数据`insert into test(id) value(1)`；

操作流程

1. 在Session1中，执行事务A`delete from test where id < 2`语句，暂不提交事务A；
2. 在Session2中，执行事务B`insert into test(id) value(1)`语句，立即提交事务B；
3. 在Session1中，提交事务A;

原因分析

由于事务提交的先后顺序，决定了基于STATEMENT格式的binlog中记录两条SQL语句的先后次序，即同步到从库时执行两条SQL的先后顺序；在主库中，事务A执行完删除语句后，尚未提交事务之前，事务B执行了插入语句并且提交了事务，事务A此时再提交事务，主库中id=1的数据是存在的；但是binlog会顺序记录`insert into test(id) value(1)`->`delete from test where id < 2`两条SQL，在从库执行后，从库中id=1的数据是不存在的；从而导致了在`读已提交(Read Commited)`这个隔离级别，基于STATEMENT格式的binlog主从同步，会存在主从数据不一致的BUG。改为使用`可重复读(REPEATABLE RAED)`隔离级别，则在事务A执行的时候，会使用间隙锁用于锁定(-∞~1]的范围，阻止事务B在事务A提交之前执行，从而解决幻读的问题；

---

## MVCC（多版本并发控制）

英文全称为Multi-Version Concurrency Control，乐观锁为理论基础的MVCC（多版本并发控制），MVCC的实现没有固定的规范。每个数据库都会有不同的实现方式。

MVCC多版本并发控制中的读操作分为两类: `快照读 snapshot read` 与 `当前读 current read`

* `快照读 snapshot read`是通过MVCC+undo log实现保证不会产生幻读情况；
* `当前读 current read` 是通过记录锁（读写锁）+ 间隙锁实现保证不会产生幻读情况；

InnoDB通过间隙锁解决幻读`快照读 snapshot read`，即不仅要为查询条件范围内存在的数据行加锁，还要为查询范围内不存在的数据行加锁，以防止查询条件范围内的删除或插入操作；

InnoDB通过MVCC解决幻读`当前读 current read`；

---

## 日志序列号

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

## 刷盘策略

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

## 事务流程

### 事务执行流程

1. 更新ID=1的收据，首先取ID=1的行数据；
2. 数据是否在内存中，不在则从磁盘加载；
3. 返回行数据将这行的数据+1；
4. 写入新的行；
5. 新行更新到内存；
6. Innodb Engine写redolog，事务处于`prepare阶段`；
7. MySQL Server写binlog；
8. Innodb Engine写redolog，事务处于`commit阶段`；

### 崩溃恢复规则

1. 如果 redo log 里面的事务是完整的，也就是已经有了 commit 标识，则直接提交；
2. 如果 redo log 里面的事务只有完整的 prepare，则判断对应的事务 binlog 是否存在并完整：a.如果是，则提交事务；b.否则，回滚事务；

### 崩溃场景分析

在两阶段提交的不同时刻，MySQL 发生崩溃下的场景分析：

* 如果在步骤7之前 MySQL发生崩溃，也就是写入 redo log 处于 prepare 阶段之后、写 binlog 之前发生了崩溃，由于此时 binlog 还没写，redo log 也还没提交，所以崩溃恢复的时候，这个事务会回滚。这时候，binlog 还没写，所以也不会传到备库。

* 如果在时刻7之后 MySQL发生崩溃，也就是 binlog 写完，redo log 还没 commit 前发生崩溃，根据崩溃恢复规则，对应的就是2(a)的情况，崩溃恢复过程中事务会被提交。

>问题🤔️：MySQL 怎么知道 binlog 是完整的?

一个事务的 binlog 是有完整格式的：

* statement 格式的 binlog，最后会有 COMMIT；
* row 格式的 binlog，最后会有一个 XID event。

另外，在 MySQL 5.6.2 版本以后，还引入了 binlog-checksum 参数，用来验证 binlog 内容的正确性。对于 binlog 日志由于磁盘原因，可能会在日志中间出错的情况，MySQL 可以通过校验 checksum 的结果来发现。

>问题🤔️：redo log 和 binlog 是怎么关联起来的?

它们有一个共同的数据字段，叫 XID。崩溃恢复的时候，会按顺序扫描 redo log：

* 如果碰到既有 prepare、又有 commit 的 redo log，就直接提交；
* 如果碰到只有 parepare、而没有 commit 的 redo log，就拿着 XID 去 binlog 找对应的事务；

>问题🤔️：处于 prepare 阶段的 redo log 加上完整 binlog，重启就能恢复，MySQL 为什么要这么设计?

其实，这个问题还是跟我们在反证法中说到的数据与备份的一致性有关。在时刻 B，也就是 binlog 写完以后 MySQL 发生崩溃，这时候 binlog 已经写入了，之后就会被从库（或者用这个 binlog 恢复出来的库）使用。所以，在主库上也要提交这个事务。采用这个策略，主库和备库的数据就保证了一致性。

>问题🤔️：如果这样的话，为什么还要两阶段提交呢？干脆先 redo log 写完，再写 binlog。崩溃恢复的时候，必须得两个日志都完整才可以。是不是一样的逻辑？

回答：其实，两阶段提交是经典的分布式系统问题，并不是 MySQL 独有的。如果必须要举一个场景，来说明这么做的必要性的话，那就是事务的持久性问题。对于 InnoDB 引擎来说，如果 redo log 提交完成了，事务就不能回滚（如果这还允许回滚，就可能覆盖掉别的事务的更新）。而如果 redo log 直接提交，然后 binlog 写入的时候失败，InnoDB 又回滚不了，数据和 binlog 日志又不一致了。两阶段提交就是为了给所有人一个机会，当每个人都说“我 ok”的时候，再一起提交。

>问题🤔️：不引入两个日志，也就没有两阶段提交的必要了。只用 binlog 来支持崩溃恢复，又能支持归档，不就可以了？

我把这个问题再翻译一下的话，是说只保留 binlog，然后可以把提交流程改成这样：… -> "数据更新到内存" -> "写 binlog" -> "提交事务"，是不是也可以提供崩溃恢复的能力？
如果说历史原因的话，那就是 InnoDB 并不是 MySQL 的原生存储引擎。MySQL 的原生引擎是 MyISAM，设计之初就有没有支持崩溃恢复。
InnoDB 在作为 MySQL 的插件加入 MySQL 引擎家族之前，就已经是一个提供了崩溃恢复和事务支持的引擎了。
InnoDB 接入了 MySQL 后，发现既然 binlog 没有崩溃恢复的能力，那就用 InnoDB 原有的 redo log 好了。
而如果说实现上的原因的话，就有很多了。就按照问题中说的，只用 binlog 来实现崩溃恢复的流程，我画了一张示意图，这里就没有 redo log 了。
prepare1->binlog1->commit1->prepare2->binlog2->crash->commmit2
这样的流程下，binlog 还是不能支持崩溃恢复的。我说一个不支持的点吧：binlog 没有能力恢复“数据页”。
如果在图中标的位置，也就是 binlog2 写完了，但是整个事务还没有 commit 的时候，MySQL 发生了 crash。
重启后，引擎内部事务 2 会回滚，然后应用 binlog2 可以补回来；但是对于事务 1 来说，系统已经认为提交完成了，不会再应用一次 binlog1。
但是，InnoDB 引擎使用的是 WAL 技术，执行事务的时候，写完内存和日志，事务就算完成了。如果之后崩溃，要依赖于日志来恢复数据页。
也就是说在图中这个位置发生崩溃的话，事务 1 也是可能丢失了的，而且是数据页级的丢失。此时，binlog 里面并没有记录数据页的更新细节，是补不回来的。
你如果要说，那我优化一下 binlog 的内容，让它来记录数据页的更改可以吗？可以，但这其实就是又做了一个 redo log 出来。
所以，至少现在的 binlog 能力，还不能支持崩溃恢复。

>问题🤔️：那能不能反过来，只用 redo log，不要 binlog？

如果只从崩溃恢复的角度来讲是可以的。你可以把 binlog 关掉，这样就没有两阶段提交了，但系统依然是 crash-safe 的。
但是，如果你了解一下业界各个公司的使用场景的话，就会发现在正式的生产库上，binlog 都是开着的。因为 binlog 有着 redo log 无法替代的功能。
一个是归档。redo log 是循环写，写到末尾是要回到开头继续写的。这样历史日志没法保留，redo log 也就起不到归档的作用。
一个就是 MySQL 系统依赖于 binlog。binlog 作为 MySQL 一开始就有的功能，被用在了很多地方。其中，MySQL 系统高可用的基础，就是 binlog 复制。
还有很多公司有异构系统（比如一些数据分析系统），这些系统就靠消费 MySQL 的 binlog 来更新自己的数据。关掉 binlog 的话，这些下游系统就没法输入了。总之，由于现在包括 MySQL 高可用在内的很多系统机制都依赖于 binlog，所以 redo log 还做不到。

## 参考资料

* [https://www.infoq.cn/article/M6g1yjZqK6HiTIl_9bex][1]{:target="_blank"}

[1]:https://www.infoq.cn/article/M6g1yjZqK6HiTIl_9bex
