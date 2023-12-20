---
layout: post
title: 分布式全局唯一ID服务
categories: distributed
tags: distributed id
---

### 分布式GlobalId设计的目标

---

分布式GlobalId设计的目标要求满足以下特点：

* 唯一性：不能出现重复的ID号，既然是全局唯一标识，这是最基本的要求。
* 递增性：递增性又分为`趋势递增`和`单调递增`。

    `趋势递增`：在MySQL InnoDB引擎中使用的是聚集索引，由于多数RDBMS使用B-tree的数据结构来存储索引数据，在主键的选择上面我们应该尽量使用有序的主键保证写入性能；

    `单调递增`：保证下一个ID一定大于上一个ID，例如事务版本号、IM增量消息、排序等特殊需求。

* 高可用：确保任何时候都能生成正确的ID。
* 高并发：在高并发的环境下依然表现良好。
* 规整性：确保生成的GlobalId，其长度是有固定的。

---

### UUID

UUID(Universally Unique Identifier)的标准型式包含32个16进制数字，以连字号分为五段，形式为8-4-4-4-12的36个字符，示例：`550e8400-e29b-41d4-a716-446655440000`，到目前为止业界一共有5种方式生成 UUID，详情见 IETF 发布的 UUID 规范 [A Universally Unique IDentifier (UUID) URN Namespace][3]{:target="_blank"}。

---

#### UUID优势

1. 生成性能高：本地生成，没有网络消耗。

#### UUID劣势

1. 不易于存储：UUID太长，16字节128位，通常以36长度的字符串表示，很多场景不适用。
2. 信息不安全：基于MAC地址生成UUID的算法可能会造成MAC地址泄露，这个漏洞曾被用于寻找梅丽莎病毒的制作者位置。
3. 无递增特性：比如作为 MySQL 数据库主键，在 InnoDB 引擎下，UUID 的无序性可能会引起数据位置频繁变动，严重影响性能。

---

### SnowFlake

对于分布式的ID生成，以 Twitter Snowflake 为代表的， Flake 系列算法，属于划分命名空间并行生成的一种算法，生成的数据为64bit的long型数据，在数据库中应该用大于等于64bit的数字类型的字段来保存该值，比如在 MySQL 中应该使用 BIGINT。

![snowflake-64bit](/assets/img/2dcc8af7-c6a6-4bb6-aa2e-0ba2acb22669.jpg){:width="100%"}

{:class="table table-striped table-bordered table-hover"}
| <img style="width:80px">长度 | <img style="width:80px">描述 | <img style="width:150px">解释 | 取值范围 |
| ------- | ---------  | --------------- | ------ |
| 1-bit   | reserved   | 保留字段，默认：0 | 0 |
| 41-bit  | timestamp  | 当前的时间戳，单位：ms  | 0 ~ 2199023255551(2^41-1)，对应时间范围：1970-01-01 08:00:00 ~ 2039-09-07 23:47:35，时间跨度约69年。|
| 10-bit  | worker id  | 工作节点编号      | 0 ~ 1023(2^10-1) |
| 12-bit  | sequence   | 毫秒内序列号      | 0 ~ 4095(2^12-1) |

---

#### Snowflake优势

1. 唯一标识趋势递增：毫秒数在高位，自增序列在低位，整个ID都是趋势递增的。
2. 不依赖第三方系统：以服务的方式部署，不依赖数据库，稳定性更高，并且无状态更易于水平扩容。
3. 唯一标识生成高效：雪花算法的生成效率非常高。

---

#### Snowflake劣势

1. 强依赖于机器时钟：雪花算法强依赖机器时钟，如果机器上时钟发生回拨，会导致发号重复或者服务会处于不可用状态。
2. 全局无法单调递增：在单机上是单调递增的，但是设计到分布式环境中，每台机器上的时钟无法做到完全同步，全局上是趋势递增，无法满足要求单调递增发号的业务。

---

#### 如何解决workerId分配问题？

在相同的 reserved、timestamp、workerId 情况下，即每个全局唯一ID生成的工作节点，每毫秒可以生成`2^12=4096`个唯一标识，可以满足单节点`4096/ms`的QPS。
如果每毫秒生成了4096个全局唯一ID，那么，Snowflake 算法会阻塞直到进入下一毫秒才会继续生成新的全局唯一ID。

在分布式环境中，通过对全局唯一ID服务扩展workerId节点的方式，可以快速满足更高的发号需求。

但这要保证分配的`workerId`也是全局唯一的，不会存在重复的情况，因此，常见的`workerId`分配方式有如下几种：

* 通过实现分布式一致性协议算法的服务分配`workerId`，比如部署zookeeper集群，用于工作节点启动时，获取全局唯一的`workerId`。
* 通过集群中工作节点本地IP地址生成唯一识别，前提是工作节点的IP网关有规划，不会出现重复的场景。

#### 如何解决机器时钟回拨问题？

问题🤔️：由于Snowflake算法依赖本地时钟，一旦机器时钟回拨会导致41bit的时间戳重复的问题，导致在相同的workerId节点，产生重复的uniqId；

解决：？？？

### 参考资料

* [https://cloud.tencent.com/developer/article/1074907][1]{:target="_blank"}
* [https://tech.meituan.com/2017/04/21/mt-leaf.html][2]{:target="_blank"}
* [https://www.ietf.org/rfc/rfc4122.txt][3]{:target="_blank"}

[1]:https://cloud.tencent.com/developer/article/1074907
[2]:https://tech.meituan.com/2017/04/21/mt-leaf.html
[3]:https://www.ietf.org/rfc/rfc4122.txt
