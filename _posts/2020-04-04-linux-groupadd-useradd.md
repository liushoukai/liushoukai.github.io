---
layout: post
title: linux groupadd useradd
categories: linux-shell
tags: linux shell
---

分组：`/etc/group /etc/gshadow`
用户：`/etc/passwd /etc/shadow`

帐号UID范围：定义在/etc/login.defs文件中，由UID_MIN与UID_MAX决定（Ubuntu14.04 1000-60000）
系统帐号UID范围：定义在/etc/login.defs文件中，由SYS_UID_MIN与SYS_UID_MAX决定（Ubuntu14.04 100-999）
查看单个用户的用户组：id kay
查看用户的登录信息：finger kay
查看多个用户的用户组：groups kay
添加用户到指定组：usermod -a -G testgroup kay
从指定组中移除用户：gpasswd -d vita group1
创建用户家目录：cp -a /etc/skel /home/vita
强制用户首次登录后修改密码：chage -d 0 vita
查看：cat /etc/passwd |awk -F \: '{print $1}'
创建系统用户：useradd -r -g kay -d /home/kay -s /bin/bash kay
删除用户及其家目录：userdel -r kay
修改用户密码：passwd kay
检查用户帐号配置：pwck
检查用户组配置：grpck

## 添加登录帐号

```shell
Usage: useradd [options] LOGIN
       useradd -D
       useradd -D [options]
Options: 
-b, --base-dir BASE_DIR       设置基本路径作为用户的登录目录 
-c, --comment COMMENT         对用户的注释 
-d, --home-dir HOME_DIR       设置用户的登录目录 
-D, --defaults                改变设置 
-e, --expiredate EXPIRE_DATE  设置用户的有效期 
-f, --inactive INACTIVE       用户过期后，让密码无效 
-g, --gid GROUP               使用户只属于某个组 
-G, --groups GROUPS           使用户加入某个组 
-k, --skel SKEL_DIR           指定其他的skel目录 
-K, --key KEY=VALUE           覆盖/etc/login.defs配置文件 
-m, --create-home             自动创建登录目录 
-l,                           不把用户加入到lastlog文件中 
-M,                           不自动创建登录目录 
-r,                           建立系统账号 
-o, --non-unique              允许用户拥有相同的UID
-p, --password PASSWORD       为新用户使用加密密码
-s, --shell SHELL             登录时候的shell
-u, --uid UID                 为新用户指定一个UID 
```

```shell
# 添加用户组
groupadd ponderers

# 创建登录用户
sudo useradd -r -g ponderers -m -d /home/kay -s /bin/bash kay
sudo useradd -r -g ponderers -m -d /home/liushoukai -s /bin/bash liushoukai
sudo useradd -r -g ponderers -m -d /home/deployment -s /bin/bash deployment

# 将用户kay添加至sudo组
usermod -a -G sudo kay

# 创建非登录用户
groupadd woker
groupadd mysql && useradd -g mysql -s /usr/sbin/nologin mysql
groupadd nginx && useradd -g nginx -s /usr/sbin/nologin nginx
groupadd nexus && useradd -g nexus -s /usr/sbin/nologin nexus
groupadd otter && useradd -g otter -s /usr/sbin/nologin otter
groupadd redis && useradd -g redis -s /usr/sbin/nologin redis
groupadd nacos && useradd -g nacos -s /usr/sbin/nologin nacos

groupadd zookeeper && useradd -g zookeeper -s /usr/sbin/nologin zookeeper
groupadd ponderers && useradd -g ponderers -s /usr/sbin/nologin ponderers

# 创建目录的账号
sudo mkhomedir_helper zookeeper

# 为用户kay添加用户组systemd-journal
sudo usermod -a -G systemd-journal kay

# 设置用户密码
passwd kay

# 查看用户
id kay

# 修改软链接所属用户及分组
chown -h username:groupname symbolic

# 查看系统上的所有组
getent group
```
