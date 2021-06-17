---
layout: post
title: linux-apt-rpm
categories: linux-shell
tags: linux shell
---

## apt

```shell
# 修改apt源
sudo sed -i'.bak' "s/us.archive/cn.archive/g" /etc/apt/sources.list

# 软件包安装
dpkg -i package-file-name.deb

# 删除包及其配置
sudo apt -y autoremove --purge libncurses5-dev

# 软件安装
sudo apt update
sudo apt upgrade
sudo apt install man vim openssh-server git lrzsz curl expect pinfo htop pinfo build-essential openssh-server python-dev cmake tree

# 仅安装安全更新

# 发行版包管理
yum -y install python-devel
apt -y install python-dev

# 软件包降级
sudo apt install libuuid1=2.27.1-6ubuntu3

# 使用aptitude安装软件（注：使用aptitude可以只能处理包降级冲突）
sudo apt install aptitude
sudo aptitude install myNewPackage

# 查询软件包正向依赖
apt-cache depends libphp-jabber

# 查询软件包反向依赖
apt-cache rdepends php5
```

## rpm与dpkg

```shell
# 安装
rpm -i xxx.rpm
dpkg -i xx.deb

# 查询
rpm -qa == dpkg -l
rpm -ql xxx == dpkg -L xxx
rpm -qf dpkg -S /path/to/file == dpkg -S /path/to/file

# 查询安装软件信息
rpm -qip pkgfile.rpm (显示软件信息)
rpm -qlp pkgfile.rpm (显示软件内所有档案)

dpkg -I pkgfile.deb (大写I )
dpkg -c pkgfile.deb

# 显示指定套件是否安装
rpm -q softwarename (只显示套件名称)
rpm -qi softwarename (显示套件资讯)
dpkg -l softwarename (小写L,只列出简洁资讯)
dpkg -s softwarename (显示详细资讯)
dpkg -p softwarename (显示详细资讯)

# 移除指定套件
rpm -e softwarename
dpkg -r softwarename (会留下套件设定档)
dpkg -P softwarename (完全移除)
```

## 在Debian使用alien处理RPM套件

在Debian安装非Debian套件时，可使用alien进行安装。
alien 可处理 .deb、.rpm、.slp、.tgz 等档案格式, 进行转档或安装。

1. 安装alien套件: `apt install alien`
2. 在Debian安装RPM套件: `alien -i quota-3.12-7.i386.rpm`
3. 制作成deb的套件格式: `alien -d quota-3.12-7.i386.rpm`
4. 制作成rpm的套件格式: `alien -r quota_3.12-6_i386.deb`
