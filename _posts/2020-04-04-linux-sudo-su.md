---
layout: post
title: linux-sudo-su
categories: linux-shell
tags: linux shell
---

### 以其他用户身份执行命令

---

```shell
sudo su - platform -c "jps -lmvV"
```

---

### 安装软件使用root用户

---

Normal users on Linux run with reduced permissions – for example, they can’t install software or write to system directories.

---

### 不推荐使用root用户登录

---

Discouraging users from running as root is one of the reason why Ubuntu uses sudo instead of su.
By default, the root password is locked on Ubuntu,so average users can’t log in as root without going
out of their way to re-enable the root account.

---

### su与sudo的区别

---

  `su`：从当前用户切换到root用户，并且需要输入root用户的密码，su是传统上Linux系统获取root权限的方式。

`sudo`：使用root权限执行单条命令，并且要求输入当前帐号的密码。

使用su命令后，获取到root shell，在root shell中执行需要root权限的命令，然后退出root shell；
使用sudo命令，只是指定想要以root身份运行的命令，而不必切换到root shell；

限制危害

1. 使用用户账户登录，你运行的程序只能写到你自己的目录中，在没有获得root权限的情况下，你无法修改系统文件
2. 如果应用程序Firefox存在安全漏洞，恰好你又在使用root权限运行Firefox，那么而已的网页会有权读写系统的所有文件

>Well, to put it simply, installing as a root does not allow any of the user to alter the programs/applications installed.In general, it is always recommended to install some sensitive applications(depending upon scenario based usage), as root.
