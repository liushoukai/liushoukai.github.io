---
layout: post
title: linux-tc-tcpdump
categories: linux-shell
tags: tc tcpdump
---

# tcpdump

是数据包嗅探工具，可以抓取流动在网卡上的数据包
默认情况，tcpdump不会抓取本机内部的通讯报文。根据网络协议栈的规定，对于报文，即使是目的地是本机，
也需要经过本季度额网络协议层，所以本机通讯肯定是通过API进入了内核，并且完成了路由。
如果要使用tcpdump抓取其他主机MAC地址的数据包，必须开启网卡混杂模式，所谓混杂模式，用最简单的语言就是让网卡抓取任何经过它的数据包，
不管这个数据包是不是发给它或者是它发出的。一般而言，Unix不会让普通用户设置混杂模式，因为这样可以看到别人的信息，比如telnet的用户名和密码，
这样会引起一些安全上的问题，所以只有root用户可以开启混杂模式，
```shell
开启混杂模式的命令是：ifconfig en0 promisc, 其中，en0是你要打开混杂模式的网卡。

// 指定主机
tcpdump host 172.26.41.23
tcpdump src host 172.26.41.23
tcpdump dst host 172.26.41.23

// 指定网卡与协议
tcpdump -i eth0
tcpdump -i eth0 arp
tcpdump -i eth0 tcp
tcpdump -i eth0 udp
tcpdump -i eth0 ip
tcpdump -i eth0 icmp

// 指定端口
tcpdump port 80
tcpdump src port 80
tcpdump dst port 80

// 抓去主机10.37.63.255与主机10.37.63.61之间的数据包
sudo tcpdump host 10.37.63.255 and 10.37.63.61


使用tcpdump抓包
1. 抓取源/目的地址为10.37.63.255的网络数据，并保存到wiki.pcap文件
sudo tcpdump host 172.26.41.23 -w /tmp/.pcap

2.使用Fiddler、Wireshark分析数据包
Fiddler: File->Import Sessions->Packet Capture

1.通过tcpdump命令抓包，然后通过wireshark进分析
sudo tcpdump tcp port 80 -n -s 0 -w /tmp/tcp2.cap

2.直接在终端输出抓包信息
sudo tcpdump tcp port 80 -n -s 0

抓取服务探针流量
nohup timeout 3600 tcpdump -i any -A -s 0 -l 'tcp dst port 12002 and (dst host 10.1.174.40 or 127.0.0.1) and (src host !10.1.170.146 and !10.1.173.129 and !10.1.170.153) and (((ip[2:2] - ((ip[0]&0xf)<<2)) - ((tcp[12]&0xf0)>>2)) != 0)' > /data1/upload/12002.pcap 2>&1 &
```

# tc

流量控制的一个基本概念是队列(Qdisc)，每个网卡都与一个队列(Qdisc)相联系。
每当内核需要将报文分组从网卡发送出去，都会首先将该报文分组添加到该网卡所配置的队列中，由该队列决定报文分组的发送顺序。
因此可以说，所有的流量控制都发生在队列中。有些队列的功能是非常简单的，它们对报文分组实行先来先走的策略。
有些队列则功能复杂，会将不同的报文分组进行排队、分类，并根据不同的原则，以不同的顺序发送队列中的报文分组。
为实现这样的功能，这些复杂的队列需要使用不同的过滤器(Filter)来把报文分组分成不同的类别(Class)。
这里把这些复杂的队列称为可分类(Classiful)的队列。通常，要实现功能强大的流量控制，可分类的队列是必不可少的。
因此，类别(Class)和过滤器(Filter)也是流量控制的另外两个重要的基本概念。
类别(Class)和过滤器(Filter)是队列的内部结构，并且可分类的队列可以包含多个类别，同时，一个类别又可以进一步包含有子队列，或者子类别。
所有进入该类别的报文分组可以依据不同的原则放入不同的子队列 或子类别中，以此类推。
而过滤器(Filter)是队列用来对数据报文进行分类的工具，它决定一个数据报文将被分配到哪个类别中。

```shell
查看TC设置
$ tc -s qdisc show dev eth0
qdisc netem 8001: root refcnt 2 limit 1000 delay 100.0ms
Sent 12412 bytes 78 pkt (dropped 0, overlimits 0 requeues 0)
backlog 150b 1p requeues 0

利用TC命令增加延迟情况
sudo tc qdisc add dev eth0 root netem delay 100ms
sudo tc qdisc del dev eth0 root netem delay 100ms
...
sudo tc qdisc add dev eth0 root netem delay 500ms
sudo tc qdisc del dev eth0 root netem delay 500ms

利用TC命令增加丢包情况
sudo tc qdisc add dev eth0 root netem loss 1%
sudo tc qdisc del dev eth0 root netem loss 1%
...
sudo tc qdisc add dev eth0 root netem loss 10%
sudo tc qdisc del dev eth0 root netem loss 10%


模拟包重复:
# tc qdisc add dev eth0 root netem duplicate 1%

该命令将 eth0 网卡的传输设置为随机产生 1% 的重复数据包 。6 模拟数据包损坏:

# tc qdisc add dev eth0 root netem corrupt 0.2%

该命令将 eth0 网卡的传输设置为随机产生 0.2% 的损坏的数据包 。 (内核版本需在 2.6.16 以上)

模拟数据包乱序:
# tc qdisc change dev eth0 root netem delay 10ms reorder 25% 50%

该命令将 eth0 网卡的传输设置为:有 25% 的数据包(50%相关)会被立即发送,其他的延迟10 秒。

新版本中,如下命令也会在一定程度上打乱发包的次序:# tc qdisc add dev eth0 root netem delay 100ms 10ms
```

# 参考资料
http://blog.jobbole.com/101476/
