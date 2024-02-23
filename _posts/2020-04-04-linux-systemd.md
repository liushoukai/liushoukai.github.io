---
layout: post
title: linux systemd systemctl journalctl
categories: linux-shell
tags: linux shell
---

## Systemd介绍

Systemctl是Systemd中的一个工具，主要负责控制Systemd系统和服务管理器。
Systemd是一个管理系统守护进程的工具集和类库，用于替代传统的System V init管理模式。
Systemd通常作为其他守护进程的父进程。

```shell
# 检查系统是否安装Systemd
systemd —version
whereis systemd systemctl

# 分析Systemd启动过程
systemd-analyze
systemd-analyze critical-chain
systemd-analyze critical-chain nginx.service

# 启动/重启/停止服务
sudo systemctl start nginx.service          #启动服务
sudo systemctl restart nginx.service        #重启服务
sudo systemctl stop nginx.service           #优雅停止
sudo systemctl kill nginx.service           #强制停止
sudo systemctl enable nginx.service         #打开开机启动
sudo systemctl disable nginx.service        #关闭开机启动
sudo systemctl is-enabled nginx.service     #是否开机启动
sudo systemctl cat nginx.service            #查看配置
sudo systemctl list-unit-files|grep enabled #查看已启动的服务列表
```

## Systemd配置文件

UNIT的文件位置一般主要有三个目录，这三个目录的配置文件优先级依次从高到低，如果同一选项三个地方都配置了，优先级高的会覆盖优先级低的。

|Path|Description|
|---|---|
| /etc/systemd/system | Local configuration |
| /run/systemd/system | Runtime units |
| /lib/systemd/system | Units of installed packages |

```shell
# 修改Systemd服务配置文件后，必须重新加载配置
sudo vim /lib/systemd/system/nginx.service
sudo systemctl daemon-reload

# 查看服务日志
sudo journalctl -fn 20 -u rabbitmq-server.service
```

## 参考资料

http://www.ruanyifeng.com/blog/2016/03/systemd-tutorial-part-two.html
