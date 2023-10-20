---
layout: post
title: 搭建Nexus仓库
categories: java
tags: java maven nexus
---

## Nexus 安装配置

[NEXUS REPOSITORY MANAGER 3 系统配置要求]
(https://help.sonatype.com/repomanager3/product-information/sonatype-nexus-repository-system-requirements){:target="_blank"}

### Nexus下载地址

[http://nexus.sontatype.org/downloads/][1]{:target="_blank"}

- Nexus默认端口：8081，通过`conf/nexus.properties`修改服务端口
- Nexus默认账号：admin/admin123

### Nexus运行用户

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

### 修改启动脚本

修改`/bin/nexus`文件，设置JAVA_HOME目录。注意⚠️：要求使用JAVA8且不支持OpenJDK实现。

```shell
# Uncomment the following line to override the JVM search sequence
INSTALL4J_JAVA_HOME_OVERRIDE="/data/service/jdk1.8.0_321/"
# Uncomment the following line to add additional VM parameters
INSTALL4J_ADD_VM_PARAMS=-Djava.util.prefs.userRoot=../sonatype-work/nexus3/prefs
```

### 修改日志目录

创建软链接 `sonatype-work/nexus3/log -> /data/log/nexus/`

```shell
% tree sonatype-work -L 2
sonatype-work
└── nexus3
    ├── backup
    ├── blobs
    ├── cache
    ├── db
    ├── dbback
    ├── elasticsearch
    ├── etc
    ├── generated-bundles
    ├── instances
    ├── karaf.pid
    ├── keystores
    ├── lock
    ├── log -> /data/log/nexus
    ├── orient
    ├── port
    ├── prefs
    ├── restore-from-backup
    ├── tmp
    └── upgrades
```

将标准IO输出从 `/dev/null` 改为 `/data/log/nexus/stdout.log`，避免启动错误被吞掉。

```shell
case "$1" in
    start)
    ¦   echo "Starting nexus"

$INSTALL4J_JAVA_PREFIX nohup "$app_java_home/bin/java" -server -Dinstall4j.jvmDir="$app_java_home" -Dexe4j.moduleName="$prg_dir/$progname" "-XX:+UnlockDiagnosticVMOptions" "-Dinstall4j.launcherId=245" "-Dinstall4j.swt=false" "$vmov_1" "$vmov_2" "$vmov_3" "$vmov_4" "$vmov_5" $INSTALL4J_ADD_VM_PARAMS -classpath "$local_classpath" com.install4j.runtime.launcher.UnixLauncher start 9d17dc87 "" "" org.sonatype.nexus.karaf.NexusMain  > /data/log/nexus/stdout.log 2>&1 &
```

## Nexus仓库类型

- group 仓库组：Nexus通过仓库组的概念同意管理多个仓库
- hosted 宿主仓库：即私人仓库，用于存放上传的Nexus私服的构建，包括maven-releases与maven-snapshots两个；
- proxy 代理仓库：代理公共的远程仓库；
- virtual 虚拟仓库：用于适配 Maven 1

## Nexus仓库策略

- releases 发布版本仓库
- snapshot 快照版本仓库

## Nexus仓库配置

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

## 参考资料

1.[http://nexus.sontatype.org/downloads/][1]{:target="_blank"}

[1]:http://nexus.sontatype.org/downloads/
