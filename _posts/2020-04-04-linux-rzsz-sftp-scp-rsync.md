---
layout: post
title:  文件传输协议
categories: linux-shell
tags: rzsz rsync scp
---

## sftp

lftp user@192.168.56.100 使用端口21，只有远程主机上安装有FTP服务器才能使用FTP

sftp是一个交互式文件传输程式，其它类似于ftp, 但它进行加密传输，比FTP有更高的安全性
sftp -oPort=22 user@192.168.56.100

## scp

SCP(Secure Copy 安全复制)是一项比传统远程复制工具RCP更安全的文件复制技术。
文件都是通过SSH加密通道进行传输的，需要实现SSH自动登录，SCP就可以直接执行。

类似的工具有rsync；scp消耗的资源少，不会提高多少系统负荷。
rsync比scp会快一点，但是当小文件多的情况下，rsync会导致磁盘I/O非常高，而scp基本不影响系统正常使用。

```shell
# 将本地文件复制到远程IP主机
scp -P 31931 -C app_g.20170315.sql kay@192.168.56.100:/tmp/

# 将远程IP主机文件复制到本地
scp -i ~/.ssh/Identity -P 32200 -C kay@172.28.20.50:/tmp/dp_user.dat /data/

# 将目录/home/slynux递归复制到远程主机中
scp -r /home/slynux user@remotehost:/home/backups

# -p选项能够在复制文件的同时保留文件的权限和模式
scp -v -P 31931 ./redis-2.2.8.tgz kay@192.168.56.100:/tmp
```

## rsync

rsync命令使用SSH连接远程主机，rsync通常会询问SSH连接的密码，可以通过使用SSH密钥来实现自动化
默认端口：873

```shell
-a 表示要进行归档
-z 指定在网络传输时使用压缩数据以改善传输速度

//配置文件
/etc/rsyncd.conf rsync

//将源目录复制到目的端
rsync -av /data/shell/bashnote/ /data/sanbox/

//将源目录复制到远程目的端，可以通过定期执行来维护一份镜像
rsync -avz /data/shell/bashnote/ kay@192.168.214.137:/data/

//将远程目的端数据恢复到本地主机
rsync -avz kay@192.168.214.137:/data/ /data/sanbox/

//在归档时使用--exclude排除部分文件
rsync -avz /data/sanbox/ kay@192.168.214.137:/data/test --exclude "*.sh"

# 在更新rsync备份时删除不存在的文件，默认情况下，rsync并不会在目的端删除那些在源端已不存在的文件，使用rsync的--delete选项
rsync -avz /data/sanbox/ kay@192.168.214.137:/data/test --exclude "*.sh" --delete

rsync -R -topg -r  10.10.12.188::kaupload /data/www/ka.duowan.com/upload

rsync -R --timeout=20 g/2/7/3272_201eec72c1fb4df089b7a2dcdfdb3aec.jpeg www-data@10.10.12.187::popup_image/

rsync -aruvz --include "*${today}*_payinfo.txt" --include "*/" --exclude "*" 59.38.194.174::roleinfo/*  /data/rsync/gamelog/qkzj/20171023/

# 使用git编写一个定时任务将特定目录的内容提交到git服务端，在需要恢复的时候从git服务端进行恢复，相比较rsync而言可以恢复到某个具体的时间点并且有详细的备份日志信息
1. ln -s /usr/local/rsync/rsyncd.conf /etc/rsyncd.conf  
2. ln -s /usr/local/rsync/rsyncd.motd /etc/rsyncd.motd  
3. ln -s /usr/local/rsync/rsyncd.secrets  /etc/rsyncd.secrets  
```

## rzsz

### 使用方法

```shell
# -b binary 用binary的方式上传下载，不解释字符为ascii
# -e 强制escape 所有控制字符，比如Ctrl+x，DEL等

# 下载文件
sz -bye

# 上传文件
rz -bye
```

### 传输协议

`XMODEM`

Xmodem 是使用最广泛的文件传输协议之一。原始的 Xmodem 协议使用 128 字节的数据包和简单的“校验和”错误检测方法。后来的增强功能 Xmodem-CRC 使用更安全的循环冗余校验 （CRC） 方法进行错误检测。Xmodem 协议始终首先尝试使用 CRC。如果发送方不确认 CRC 请求，则接收方将切换到校验和模式并继续其传输请求。Xmodem-1KX调制解调器 1K 本质上是具有 1K（1024 字节）数据包的 Xmodem CRC。在某些系统和公告板上，它也可以称为 Ymodem。一些通信软件程序，最著名的是 Procomm Plus 1.x，也将 Xmodem-1K 列为 Ymodem。Procomm Plus 2.0 不再将 Xmodem-1K 称为 Ymodem。

`YMODEM`

Ymodem 本质上是 Xmodem 1K，允许多批处理文件传输。在某些系统上，它被列为 Ymodem Batch.Ymodem-gYmodem-g 是 Ymodem 的变体。它设计用于支持错误控制的调制解调器。此协议不提供软件纠错或恢复，但期望调制解调器提供服务。它是一种流协议，在连续流中发送和接收 1K 个数据包，直到被指示停止。它不会在发送每个区块后等待肯定的确认，而是快速连续地发送区块。如果任何区块未成功转移，则整个转移将被取消。

`ZMODEM`

Zmodem 通常是最好的协议，如果你调用的电子服务支持它。Zmodem 有两个显着的特点：它非常高效，并提供崩溃恢复。与 Ymodem-g 一样，Zmodem 不会在发送每个块后等待肯定的确认，而是快速连续发送块。如果 Zmodem 传输因任何原因被取消或中断，则传输可以在以后恢复，并且无需重新发送之前传输的信息。
