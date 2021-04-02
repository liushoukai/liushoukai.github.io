---
layout: post
title: MySQL 半同步复制
categories: database
tags: mysql
---

## 半同步复制

半同步复制（semi-synchronous replication），主库在执行完客户端提交的事务后不是立刻返回给客户端，而是等待至少一个从库接收到并写到relay log中才返回给客户端。

通过`rpl_semi_sync_master_wait_point`参数，控制半同步模式下主库在返回给会话事务成功之前提交事务的方式。

参数 rpl_semi_sync_master_wait_point 有两个值：

* AFTER_COMMIT（5.6默认值）
* AFTER_SYNC（5.7默认值，但5.6中无此模式）

## 半同步复制降级

当半同步复制发生超时时（由rpl_semi_sync_master_timeout参数控制，单位是毫秒，默认为10000，即10s），会暂时关闭半同步复制，转而使用异步复制。

当master dump线程发送完一个事务的所有事件之后，如果在rpl_semi_sync_master_timeout内，收到了从库的响应，则主从又重新恢复为半同步复制。

## AFTER_COMMIT

"Innodb Engine Commit" 在binlog提交之后；

![mysql-semi-sync](/assets/img/mysql-semi-sync/after-commit.png){:width="70%"}

master将每个事务写入binlog（sync_binlog=1），传递到slave刷新到磁盘(sync_relay=1)，同时主库提交事务。master等待slave反馈收到relay log，只有收到ACK后master才将commit OK结果反馈给客户端。

万一主机崩溃，所有提交的事务已被复制到至少一个从属服务器。

### AFTER_COMMIT幻读问题

在 MySQL 5.5 和 MySQL 5.6 中开启半同步复制时，在存储引擎会在redolog中提交了commit事件后，事务会话开始等待从库的ACK应答，在收到客户端ACK应答或者超时后，才会将事务的提交状态返回给事务会话的客户端。

存储引擎一旦在redolog中提交了commit事件后，事务就会持久化存储数据并且释放相关的锁。从而其他的事务会话可以访问已提交的数据，即使当前的事务会话仍然在等待从库的ACK应答。这将会导致一旦主库崩溃，从库升级未新的主库后，原本在旧的主库上可以查询到的数据在新的主库上查不到了(崩溃瞬间事务可能还没有复制到其他从库上），从而产生幻读的问题。

![mysql-semi-sync](/assets/img/mysql-semi-sync/phantom-read.png){:width="50%"}

## AFTER_SYNC

"Innodb Engine Commit" 在从库ACK应答之后；

![mysql-semi-sync](/assets/img/mysql-semi-sync/after-sync.png){:width="70%"}

With this feature, semi-synchronous replication is able to guarantee:

* All committed transaction are already replicated to at least one slave in case of a master crash.

That is obvious, because it cannot commit to storage engine unless the slave acknowledgement is received(or timeout).

It brings a couple of benefits to users:

* Strong Data Integrity with no phantom read.
* Ease recovery process of crashed semi-sync master servers.

master将每个事务写入binlog , 传递到slave刷新到磁盘(relay log)。master等待slave反馈接收到relay log的ack之后，再提交事务并且返回commit OK结果给客户端。 即使主库crash，所有在主库上已经提交的事务都能保证已经同步到slave的relay log中。

## 半同步复制与无损复制的对比

1.ACK的时间点不同

* 半同步复制在InnoDB层的Commit Log后等待ACK，主从切换会有数据丢失风险。
* 无损复制在MySQL Server层的Write binlog后等待ACK，主从切换会有数据变多风险。

2.主从数据一致性

* 半同步复制意味着在Master节点上，这个刚刚提交的事物对数据库的修改，对其他事物是可见的。因此，如果在等待Slave ACK的时候crash了，那么会对其他事务出现幻读，数据丢失。
* 无损复制在write binlog完成后就传输binlog，但还没有去写commit log，意味着当前这个事物对数据库的修改，其他事物也是不可见的。因此，不会出现幻读，数据丢失风险。

因此5.7引入了无损复制（after_sync）模式，带来的主要收益是解决after_commit导致的master crash后数据丢失问题，因此在引入after_sync模式后，所有提交的数据已经都被复制，故障切换时数据一致性将得到提升。

## FAQ

>问题🤔️：半同步复制崩溃的主库恢复后可以重新加入集群么？

With semisynchronous replication, if the source crashes and a failover to a replica is carried out, the failed source should not be reused as the replication source server, and should be discarded. It could have transactions that were not acknowledged by any replica, which were therefore not committed before the failover.

>问题🤔️：在AFTER_SYNC模式下，已经收到从库的ACK应答，存储引擎在redolog中提交commit事件之前主库挂了，会返回客户端事务提交失败，但是切换到新的主库事务实际又执行成功了？

？？？

## 参考资料

* [http://my-replication-life.blogspot.com/2013/09/loss-less-semi-synchronous-replication.html][1]{:target="_blank"}
* [https://dev.mysql.com/doc/refman/5.7/en/replication-semisync.html][2]{:target="_blank"}

[1]:http://my-replication-life.blogspot.com/2013/09/loss-less-semi-synchronous-replication.html
[2]:https://dev.mysql.com/doc/refman/5.7/en/replication-semisync.html
