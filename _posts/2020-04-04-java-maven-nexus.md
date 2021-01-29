---
layout: post
title: Maven搭建Nexus仓库
categories: java
tags: java maven nexus
---

### Nexus 安装配置

---

Nexus下载地址
[http://nexus.sontatype.org/downloads/][1]{:target="_blank"}

- Nexus默认端口：8081，通过`conf/nexus.properties`修改服务端口
- Nexus默认账号：admin/admin123

```shell
# 创建nexus用户（注意⚠️：Nexus会使用运行程序用户的home目录，用于创建锁，因此必须创建用户的home目录）
sudo groupadd nexus && sudo useradd -r -g nexus -m nexus

# 修改目录归属
sudo chown -R nexus:nexus nexus-3.8.0-02
sudo chown -R nexus:nexus sonatype-work

# Nexus服务启动命令
/bin/nexus start：在后台启动Nexus服务。
/bin/nexus console：在前台启动Nexus服务。

# 配置Nexus服务
sudo ln -s /data/service/nexus-2.13.0-01/bin/nexus /etc/init.d/nexus
update-rc.d nexus defaults
sysv-rc-conf --list | grep nexus
```

---

### Nexus仓库类型

---

- group 仓库组：Nexus通过仓库组的概念同意管理多个仓库
- hosted 宿主仓库：即私人仓库，用于存放上传的Nexus私服的构建，包括maven-releases与maven-snapshots两个；
- proxy 代理仓库：代理公共的远程仓库；
- virtual 虚拟仓库：用于适配 Maven 1

---

### Nexus仓库策略

---

- releases 发布版本仓库
- snapshot 快照版本仓库

---

### Nexus仓库配置

---

```shell
1.创建部署角色与账号
创建角色nx-deploy，赋予nx-repository-view-*-*-*权限
创建用户deployment，赋予nx-deploy角色

2.创建代理仓库
添加一个代理仓库，用于代理 Sonatype 的公共远程仓库，点击菜单Add->Proxy Repository，添加后保存。
Repository ID - sonatype
Repository Name - Sonatype Repository
Remote Storage Location - http://repository.sonatype.org/content/groups/public/
```

---

### 参考资料

---

1.[http://nexus.sontatype.org/downloads/][1]{:target="_blank"}

[1]:http://nexus.sontatype.org/downloads/
