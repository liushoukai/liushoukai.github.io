---
layout: post
title:  VirtualBox使用
categories: tool
tags: virtualbox
---

## VirtualBox网络连接方式详解

---
> 介绍VirtualBox中常见的几种网络连接方式:
网络地址转换（NAT）
桥接网卡（Bridged networking）
内部网络（Internal networking)
仅主机适配器（Host-only network）

### 网络地址转换（NAT）

网络地址转换是虚拟机访问外网最简单的方式。通常，网络地址转换不需要在宿主机上做任何网络配置。
因此，网络地址转换是VirtualBox默认的网络连接方式。

采用NAT网络连接方式的虚拟机就像一台真实存在的计算机，通过”路由“连接到外网。
这里谈到的路由实际上是指的Virtualbox网路引擎，负责将网络数据在宿主机与虚拟机之间透明的传输。
这种隔离机制通过禁止虚拟机之间相互通讯，从而使得安全性得以最大化。

NAT网络连接方式的劣势在于，这种模式类似于路由器下的私有网络，无法从外网去访问该虚拟机。
如果虚拟机要作为一台供外网访问的服务器，如果不配置端口转发，是不能够用这种方式来运行的。

虚拟机发送的网络数据帧被Virtualbox NAT引擎接收后，使用宿主机将数据重新打包发送。从外部看来，
就如同网络数据包是从宿主机上的Virtualbox应用程序发出的，使用了宿主机的IP地址。Virtualbox同时
监听网络数据回包，将数据重新打包并发送至内部的虚拟机。

虚拟机私有网络配置是通过Virtualbox内嵌的DHCP服务器获取的，分配给虚拟机的IP地址和宿主机IP地址通常大不相同，
在多网卡虚拟机使用NAT的情形下，第一块网卡使用私有网络10.0.2.0，第二块网卡使用私有网络10.0.3.0，依此类推。
如果需要修改NAT模式下私有网络的IP分配范围，请参考”微调VirtualBox的NAT引擎“。

配置NAT端口转发
虚拟机无法被宿主机与局域网内的其他机器访问，通过配置端口转发可以使得选中的服务对外可见。
Virtualbox监听宿主机的特定端口，将所有发送至该端口的数据重新发送值虚拟机。

对于虚拟机上的应用服务而言，就像被代理的服务应用是运行在宿主机上的。这也意味着你不能在宿主机相同的端口上
运行同样的的服务，然而仍可以在虚拟机中运行服务。

1、通过命令行配置端口转发

```shell
# 添加端口转发配置
VBoxManage modifyvm "ubuntu1404" --natpf1 "reportssh,tcp,,9022,,22"
# 删除端口转发配置
VBoxManage modifyvm "ubuntu1404" --natpf1 delete "reportssh"

# natpf1代表网卡1，natpf2代表网卡2，...，依次类推
# reportssh为自定义端口转发的名字
# tcp为转发的协议
```

2、通过图形界面配置端口转发

测试配置的端口转发规则是否正确

### 桥接网卡（Bridged networking）

在桥接网络中，Virtualbox使用宿主机的网卡驱动，过滤物理网卡的数据。
该驱动被称为“网络过滤”驱动。从而允许Virtualbox通过物理网卡接收发送数据，
在应用软件中创建一个新的网络接口。当虚拟机中的软件使用这个网络接口时，在
宿主机看来就如同虚拟机使用网络电缆连接到了真是的网络中，宿主机可以给虚拟机
发送数据并且接收虚拟机返回的数据。这意味着建立了其他网络与虚拟机之间的桥梁。
相当于虚拟机公用宿主机的物理网卡，因此虚拟机在宿主机的角度看来就像接入当前
局域网中一台独立的机器。

如图，宿主机与虚拟机在相同网段，宿主机IP为172.26.41.17，虚拟机IP为172.26.41.27。

### 内部网络（Internal networking)

内部网络类似于桥接网络，虚拟机能够直接同外部网络通信。然而，外部网络仅限于相同宿主机上的其他虚拟机。
尽管从技术上来讲，任何可以使用内部网络完成的都可以使用桥接网络替代，然而内部网络具备一些安全优势。
在桥接网络模式下，所有的数据包都经过宿主机的物理网卡。因此通过抓包工具如Wireshark抓取所有的数据包并审查数据。
如果出于某些原因，想在同一机器上的多个虚拟机之间进行私密的交流，桥接网络就无法做到了。虚拟机只
能相互间通信而无法连接到外网，因为虚拟机没有连接到物理网卡。

配置两台机器的内部网络

添加一个dhcp服务器

```shell
# 添加一个dhcp服务器
VBoxManage dhcpserver add --netname testlab --ip 10.10.10.1 --netmask 255.255.255.0 --lowerip 10.10.10.2 --upperip 10.10.10.12 --enable
```

配置两台虚拟机ubuntu1404与Ubuntu1401的为内部网络

验证两台机器的连通性

### 仅主机适配器（Host-only network）

Host-only网络适用于多个虚拟机相互协作的情况。例如，一台虚拟机包含web服务，另一台虚拟机包含数据库，
由于web服务需要访问数据库，可以为两台虚拟机设置设置host-only网络，确保两者在同一个私有的局域网内，
同时设置包含web服务器的虚拟机为桥接网络，从而可以通过外网访问服务器。

```shell
# 将指定客户机的网卡X修改为Host-only模式
vboxmanage modifyvm <vmname> --nic<x> hostonly

# 创建Host-only需要用到的网络
vboxmanage hostonlyif create

# 查看上一步的网络是否创建成功
vboxmanage list hostonlyifs

# 客户机开机，在宿主机上可以看到连接到这个新建网络的接口
ifconfig

# 对新建网络开启VBox提供的DHCP服务
vboxmanage dhcpserver add --netname <network_name>
```

## 安装Extension Pack

特性介绍

- Support for a virtual USB 2.0/3.0 controller (EHCI/xHCI)
- VirtualBox RDP: support for proprietary remote connection protocol developed by Microsoft and Citrix.
- PXE boot for Intel cards
- VM disk image encryption

软件安装
1.下载安装包
VirtualBox 5.1.8 Oracle VM VirtualBox Extension Pack  All supported platforms

2.安装扩展
File->Preferences->Extensions

## 安装Guest Additions

Guest Additions包含可优化操作系统以实现更佳性能和可用性的设备驱动程序和系统应用程序。

启动虚拟机->设备->安装增强功能

### FAQ

1.未能加载虚拟光盘C:\Program Files\Oracle\VirtualBox\VBoxGuestAdditions.iso到虚拟电脑CZ88.您是否要强制挂载该介质？

安装增强功能需要使用光驱加载VBoxGuestAddtions.iso虚拟光盘，VirtualBox检测到光驱已加载了其他虚拟光盘，故提示用户是否强制挂载VBoxGuestAddtions.iso虚拟光盘。
如果点击强制释放任然报错，应该将已加载的虚拟光盘右键弹出(Eject)后重试。

## 扩展安装

1. 更新apt-get，执行  apt-get update  &&  apt-get upgrade
2. 安装依赖工具，apt-get install dkms  && apt-get install build-essential
3. reboot
4. 登陆后 选择设备->安装增强功能（报错不用管 叉掉）
5. 挂载cdrom  输入 mount /dev/cdrom /mnt/  回车，如出现如下字样则表示挂载成功，挂载成功
6. 执行安装命令   /mnt/VcBoxLinuxAdditions.run
7. 执行完成后卸载   umount /mnt/
