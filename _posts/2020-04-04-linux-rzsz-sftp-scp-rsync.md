---
layout: post
title:  文件传输协议
categories: linux-shell
tags: rzsz rsync scp
---

# rzsz

文件传输协议

`XMODEM`

Xmodem is one of the most widely used file transfer protocols. The original Xmodem protocol uses 128-byte packets and a simple "checksum" method of error detection. A later enhancement, Xmodem-CRC, uses a more secure Cyclic Redundancy Check (CRC) method for error detection. Xmodem protocol always attempts to use CRC first. If the sender does not acknowledge the requests for CRC, the receiver shifts to the checksum mode and continues its request for transmission.Xmodem-1KXmodem 1K is essentially Xmodem CRC with 1K (1024 byte) packets. On some systems and bulletin boards it may also be referred to as Ymodem. Some communication software programs, most notably Procomm Plus 1.x, also list Xmodem-1K as Ymodem. Procomm Plus 2.0 no longer refers to Xmodem-1K as Ymodem.

`YMODEM`

Ymodem is essentially Xmodem 1K that allows multiple batch file transfer. On some systems it is listed as Ymodem Batch.Ymodem-gYmodem-g is a variant of Ymodem. It is designed to be used with modems that support error control. This protocol does not provide software error correction or recovery, but expects the modem to provide the service. It is a streaming protocol that sends and receives 1K packets in a continuous stream until instructed to stop. It does not wait for positive acknowledgement after each block is sent, but rather sends blocks in rapid succession. If any block is unsuccessfully transferred, the entire transfer is canceled.

`ZMODEM`

Zmodem is generally the best protocol to use if the electronic service you are calling supports it. Zmodem has two significant features: it is extremely efficient and it provides crash recovery.Like Ymodem-g, Zmodem does not wait for positive acknowledgement after each block is sent, but rather sends blocks in rapid succession. If a Zmodem transfer is canceled or interrupted for any reason, the transfer can be resurrected later and the previously transferred information need not be resent.

```shell
# -b binary 用binary的方式上传下载，不解释字符为ascii
# -e 强制escape 所有控制字符，比如Ctrl+x，DEL等

# 下载文件
sz -bye

# 上传文件
rz -bye
```

# sftp
lftp user@192.168.56.100 使用端口21，只有远程主机上安装有FTP服务器才能使用FTP

sftp是一个交互式文件传输程式，其它类似于ftp, 但它进行加密传输，比FTP有更高的安全性
sftp -oPort=22 user@192.168.56.100

# scp
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

# rsync

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

//在更新rsync备份时删除不存在的文件，默认情况下，rsync并不会在目的端删除那些在源端已不存在的文件，使用rsync的--delete选项
rsync -avz /data/sanbox/ kay@192.168.214.137:/data/test --exclude "*.sh" --delete

rsync -R -topg -r  10.10.12.188::kaupload /data/www/ka.duowan.com/upload

rsync -R --timeout=20 g/2/7/3272_201eec72c1fb4df089b7a2dcdfdb3aec.jpeg www-data@10.10.12.187::popup_image/

rsync -aruvz --include "*${today}*_payinfo.txt" --include "*/" --exclude "*" 59.38.194.174::roleinfo/*  /data/rsync/gamelog/qkzj/20171023/


使用git编写一个定时任务将特定目录的内容提交到git服务端，在需要恢复的时候从git服务端进行恢复，相比较rsync而言可以恢复到某个具体的时间点并且有详细的备份日志信息
1. ln -s /usr/local/rsync/rsyncd.conf /etc/rsyncd.conf  
2. ln -s /usr/local/rsync/rsyncd.motd /etc/rsyncd.motd  
3. ln -s /usr/local/rsync/rsyncd.secrets  /etc/rsyncd.secrets  

```