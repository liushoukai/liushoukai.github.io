---
layout: post
title: rpc
categories: rpc
tags: thrift gRpc
---

## RPC远程方法调用

尽管“调用远程方法”与“调用本地方法”只有两字之差，但若要兼顾简单、透明、性能、正确、鲁棒、一致等特点，两者的复杂度就完全不可同日而语了。且不说远程方法不能再依靠本地方法那些以内联为代表的传统编译优化来提升速度，光是“远程”二字带来的网络环境下的新问题，譬如，远程的服务在哪里（服务发现），有多少个（负载均衡），网络出现分区、超时或者服务出错了怎么办（熔断、隔离、降级），方法的参数与返回结果如何表示（序列化协议），信息如何传输（传输协议），服务权限如何管理（认证、授权），如何保证通信安全（网络安全层），如何令调用不同机器的服务返回相同的结果（分布式数据一致性）等一系列问题，全都需要设计者耗费大量精力。

## 安装thrift

```shell
brew install boost
brew install libevent
brew install thrift
```

`Thrift生成Java代码`
```shell
thrift -r --gen java -out ./src/main/gen ./demo.thrift
```

## Thrift结构

Thrift的结构一共有三层，这三层需要我们在编程的时候根据自己的需求来设置。

### Transport

传输层，定义数据传输方式，比如：网络或者文件。
每种编程语言都必须具备双向传输原始数据的通用接口，特定传输的实现对服务的开发者来说应该是透明的。
相同的应用程序代码应该能够运行在不同的传输实现上，如：TCP流套接字，内存中的原始数据或磁盘上的文件等。

- TBufferedTransport     缓冲区（常用）
- THttpClient            http
- TMemoryBuffer          内存用于I/O
- TPhpStream.php         php流的方式
- TSocket                阻塞式Socket I/O传输
- TNonblockingSocket     非阻塞Socket
- TSocketPool            Socket池
- TSocket                使用阻塞式 I/O 进行传输

TFramedTransport 使用非阻塞方式，按块的大小进行传输，类似于Java中的NIO。若使用TFramedTransport传输层，其服务器必须修改为非阻塞的服务类型，TNonblockingServerTransport类是构建非阻塞Socket的抽象类，TNonblockingServerSocket类继承TNonblockingServerTransport；

```java
// 使用TFramedTransport传输层构建的Server
TNonblockingServerTransport serverTransport = new TNonblockingServerSocket(10005);
Hello.Processor processor = new Hello.Processor(new HelloServiceImpl());
TServer server = new TNonblockingServer(processor, serverTransport);
System.out.println("Start server on port 10005 ...");
server.serve();

// 使用TFramedTransport传输层构建的Client
TTransport transport = new TFramedTransport(new TSocket("localhost", 10005));
```

TNonblockingTransport 使用非阻塞方式，用于构建异步客户端。

---

### Protocol

协议层，定义数据传输格式，比如：XML、Binary、JSON
数据类型必须有某种方式使用传输层对自身进行编码和解码。同样，应用层开发人员也不必关心协议层的实现。
无论协议层是使用XML协议或是Binary协议，对应用层来说是都透明的，关键是数据能够被确定一致的读写。
- TBinaryProtocol        二进制格式.
- TCompactProtocol       压缩格式
- TJSONProtocol          JSON格式

TCompactProtocol vs TBinaryProtocol

`TBinaryProtocol`

处理i32整型数据类型时,定义的是4个字节的数组,32位的长度正好可以保存到这4个字节组当中.如果我们分别以n1~n32来表示第1位到第32位,那么这个数组的数据结构应该为以下结构：
```c
i32out[0] {n1  ~ n8 }
i32out[1] {n9  ~ n16}
i32out[2] {n17 ~ n24}
i32out[3] {n25 ~ n32}
```

`TCompactProtocol`

在处理i32整型数据类型时,与TBinaryProtocol完全不同,采用的是1~5个字节组来保存.依然以n1~n32来表示第1位到第32位,数据结构应该为以下结构:
```c
i32out[0] {1 , 0 , 0 , 0 , n1 ~ n4}
i32out[1] {1 , n5 ~ n11}
i32out[2] {1 , n12 ~ n18}
i32out[3] {1 , n19  ~ n25}
i32out[4] {0 , n26  ~ n32}
```
TCompactProtocol每个字节的第1位是状态位，第2位到第8位保存具体的数据，这有别于TBinaryProtocol的1到8位全部保存具体数据，这也是为什么极端情况下TCompactProtocol比TBinaryProtocol多占1个字节的原因。
TCompactProtocol的字节中第1位状态位的意思是标记此字节后是否还有数据.1为有数据,0为没有数据.

对比存储十进制数值300为例

使用TBinaryProtocol来序列化存储十进制数值'300'，二进制应该为'100101100'，进行补0操作后数据为'0000 0000 0000 0000 0000 0001 0010 1100'，数据存储如下：
```c
i32out[0] {0 , 0 , 0 , 0 , 0 , 0 , 0 , 0}
i32out[1] {0 , 0 , 0 , 0 , 0 , 0 , 0 , 0}
i32out[2] {0 , 0 , 0 , 0 , 0 , 0 , 0 , 1}
i32out[3] {0 , 0 , 1 , 0 , 1 , 1 , 0 , 0}
```
使用TCompactProtocol来序列化存储十进制数值'300'，二进制应该为'100101100'，不会进行补0操作，数据存储如下：
```c
i32out[0] {1 , 0 , 0 , 0 , 0 , 0 , 1 , 0}
i32out[1] {0 , 0 , 1 , 0 , 1 , 1 , 0 , 0}
```
数据1 0010 1100的前两位10存储在i32out[0]的数据位部分，由于后续有数据，因此标志位设置为1

数据1 0010 1100的后七位010 1100存储在i32out[1]的数据位部分，由于后续无数据，因此标志位设置为0；

结论：TCompactProtocol存储十进制数值300相比TBinaryProtocol要节省2个字节的存储空间；

对比存储十进制数值429496729为例

使用TBinaryProtocol来序列化存储十进制数值429496729，二进制应该为'11001 10011001 10011001 10011001'，进行补0操作后数据为'00011001 10011001 10011001 10011001'，数据存储如下：
```c
i32out[0] {0 , 0 , 0 , 1 , 1 , 0 , 0 , 1}
i32out[1] {1 , 0 , 0 , 1 , 1 , 0 , 0 , 1}
i32out[2] {1 , 0 , 0 , 1 , 1 , 0 , 0 , 1}
i32out[3] {1 , 0 , 0 , 1 , 1 , 0 , 0 , 1}
```
使用TCompactProtocol来序列化存储十进制数值429496729，二进制应该为'11001 10011001 10011001 10011001'，不会进行补0操作，按照每7位一组'1 1001100 1100110 0110011 0011001'，数据存储如下：
```c
i32out[0] {1 , 0 , 0 , 0 , 0 , 0 , 0 , 1}
i32out[1] {1 , 1 , 0 , 0 , 1 , 1 , 0 , 0}
i32out[2] {1 , 1 , 1 , 0 , 0 , 1 , 1 , 0}
i32out[3] {1 , 0 , 1 , 1 , 0 , 0 , 1 , 1}
i32out[4] {0 , 0 , 0 , 1 , 1 , 0 , 0 , 1}
```
结论：TCompactProtocol存储十进制数值429496729相比TBinaryProtocol要多占用1个字节的存储空间；

结论：
i32储存的数据大于28bit（4*7）时，使用TBinaryProtocol序列化更节省空间；

i32存储的数据小于等于28bit（4*7）时，使用TCompactProtocol序列化更节省空间；

i32存储的28bit对应的十进制值是268435455，考虑常规传输的数值的平均值不会超过这个长度，因此，总体来说使用TCompactProtocol会更节省传输时候的带宽；

---

### Processors

最终，我们生成的代码具备处理数据流的能力，从而实现了远程调用。
Thrift服务模型
TSimpleServer  简单的单线程模型
TServerSocket
TMultiplexedProcessor复用端口
同步阻塞IO是最传统的IO模型，但是这种模型由于会阻塞线程或者进程，所以一个线程只能处理一个IO请求，由此出现IO多路复用技术，比如Linux的epoll系统调用，一个进程可以处理多个IO请求。
从上面thrift的使用中可以看到一个Server对应一个Processor和一个Transport，如果有多个服务的话，那必须要启动多个Server，占用多个端口，这种方式显然不是我们想要的，所以thrift为我们提供了复用端口的方式，通过监听一个端口就可以提供多种服务，这种方式需要用到两个类：TMultiplexedProcessor和TMultiplexedProtocol。TMultiplexedProcessor是用在服务端，多个Processor注册在其上，然后将TMultiplexedProcessor传入TServer.Args，就可以做到只启动一个Server提供多项服务。

![RENEWAL](/assets/img/660c191f-cb3c-4468-9a98-4cb399317fd0.png){:width="100%"}

---

## Thrift 时序图

`Thrift服务端调用时序图`

程序调用TThreadPoolServer的serve()方法后，Server进入阻塞监听状态，其阻塞在TServerSocket的accept方法上。当接收到来自客户端的消息后，服务器创建一个新线程处理这个消息请求，原线程再次进入阻塞状态。在新线程中，服务器通过TBinaryProtocol协议读取消息内容，调用HelloServiceImpl的helloVoid方法，并将结果写入helloVoid_result中传回客户端。

![Thrift服务端调用时序图](/assets/img/b73eb093-f236-4904-9587-36945347f047.png){:width="100%"}

`Thrift客户端调用时序图`

![Thrift客户端调用时序图](/assets/img/06864ce5-1b36-482a-9460-65ddd1c2e41d.png){:width="100%"}


