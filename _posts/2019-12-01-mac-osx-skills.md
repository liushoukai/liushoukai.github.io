---
layout: post
title: Mac OSX实用技巧
categories: Mac
tags: Mac OSX
---

## 访达侧边栏添加自定义目录

### 操作步骤

1、首先通过快捷建方式【command+ shift+ G 】到达自定义文件的地址；

2、点击【前往】按钮 或者【ENTER】按钮到达；

3、将要添加的文件夹【data】拖向左边侧边栏，即成功添加；

## 系统普通用户启动80端口

由于系统限制非root用户不能启动1024以下端口，而我们平时使用Mac一般都是非root用户，所以如果想启动80端口必须用root用户

```bash
sudo vim /etc/pf.conf
```

1.在pf.conf文件的rdr-anchor "com.apple/*"这一行后面添加如下代码

```java
rdr on lo0 inet proto tcp from any to 127.0.0.1 port 80 -> 127.0.0.1 port 8080
```

2.其中 lo0 通过 ifconfig 看自己那个设备绑定的是127.0.0.1, lo0是这个网络设备的名字。 8080是要转发的端口

```bash
sudo pfctl -f /etc/pf.conf
sudo pfctl -e
```

这时，应用启动8080端口即可以，访问的话就可以通过80端口来访问了！

## 系统完整性保护 SIP（System Integrity Protection）

### SIP是什么

在 `OS X El Capitan` 中有一个跟安全相关的模式叫 `SIP（System Integrity Protection ）` ，它禁止让软件以 `root` 身份来在 `mac` 上运行，并且对于目录 `/System 、/sbin、/usr（不包含/usr/local/）` 仅仅供系统使用，其它用户或者程序无法直接使用。

### SIP 保护功能

#### File System Protection (文件系统保护)

启用 SIP 保护后的文件系统，拒绝Root用户更改受保护的文件，即使恶意软件通过漏洞提权到Root，也无法修改受保护的系统文件。关闭  SIP 保护后，一旦 OS X 出现漏洞被恶意提权到Root后，可随意修改受保护的系统文件。另外，SIP 也可以防止用户误删系统文件导致的崩溃问题。

#### Runtime Protection (运行时保护)

OS X 所有进程都有一个对应的内核 Task ，通过 task_for_pid Mach 调用，则可以控制这个进程。Mach 同时也有很多主机特权接口，用于控制系统，严重的比如可以关闭 CPU 内核，直接挂掉系统等，如果一个系统软件使用了这种特权接口，而又有漏洞的话，那么攻击可以栈溢出入手，然后 fork/exec ，即可获得这个特权接口。SIP 运行时保护则避免了这种可能。另外，一票的动态注入程序，如 Cycript，SIMBL 等等，在 SIP 开启的状态下都无法使用，也就避免了利用这些动态注入手段非法获取信息或修改系统、应用软件动作，状态的可能。

#### Kernel Extensions (内核扩展保护)

拒绝加载任何未使用 Apple 签名的内核扩展（驱动程序）。

内核扩展绝对是完全掌握系统控制权的绝佳地点，它直接运行在内核态，也就是拥有几乎全部的系统控制权。

如果你不小心装上了一个恶意 kext，而 SIP 又没有开启的话，理论上你的系统就不再属于你了，你的任何隐私都会暴露在攻击者面前。

### 禁用 SIP 保护机制的步骤

- 重启系统，按住 `Command + R` 进入恢复模式。
- 点击顶部菜单栏 `实用工具` 中的 `终端` 。
- 输入以下命令来禁用 `SIP` 保护机制。

```bash
csrutil disable
```

- 执行后输出以下信息表示禁用成功。

```bash
Successfully disabled System Integrity Protection. Please restart the machine for the changes to take effect.
```

- 然后再次重启系统即可。
- 重新打开 `SIP` 的方法同上，只是终端中输入的命令改为以下命令。

```bash
csrutil enable
```
