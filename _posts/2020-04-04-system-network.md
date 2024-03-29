---
layout: post
title: 系统网络基础
categories: system
tags: cmd
---

## 私有网络

{:class="table table-striped table-bordered table-hover"}
| 地址段 | 网段 | 范围 | IP数量 |
| :---: | :---: | :---: | :---: |
| A段 | 10.0.0.0/8 | 10.0.0.0-10.255.255.255 | 16777212 |
| B段 | 172.16.0.0/12 | 172.16.0.0-172.31.255.255 | 1048572 |
| C段 | 192.168.0.0/16 | 192.168.0.0-192.168.255.255 | 65532 |

使用保留地址的网络只能在内部进行通信，而不能与其他网络互连。因为本网络中的保留地址同样也可能被其他网络使用，如果进行网络互连，那么寻找路由时就会因为地址的不唯一而出现问题。

但是这些使用保留地址的网络可以通过将本网络内的保留地址翻译转换成公共地址的方式实现与外部网络的互连。这也 是保证网络安全的重要方法之一。

交换机的网段不能和所属的专有网络的网段重叠，可以是其子集或者相同，网段大小在16位网络掩码与29位网络掩码之间。

## VPC与基础网络

经典网络：公有云上所有用户共享公共网络资源池，用户之间未做逻辑隔离。用户的内网IP由系统统一分配，相同的内网IP无法分配给不同用户。

VPC：是在公有云上为用户建立一块逻辑隔离的虚拟网络空间。在VPC内，用户可以自由定义网段划分、IP地址和路由策略，安全可提供网络ACL及安全组的访问控制，因此，VPC有更高的灵活性和安全性。

经典网络和VPC的架构对比图：

![Alt text](/assets/img/80dee067-d16c-46e0-98a1-084cae3be379.png)

## Github DNS

在  查询以下域名的 A Records 解析的IP地址。

- github.com
- raw.githubusercontent.com

修改/etc/hosts，增加上面的hosts
