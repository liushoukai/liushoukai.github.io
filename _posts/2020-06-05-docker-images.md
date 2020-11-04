---
layout: post
title: Docker镜像
categories: docker
tags: docker kubernetes
---



### 镜像仓库

本地镜像都保存在 Docker 宿主机的 /var/lib/docker 目录下。镜像从仓库下载而来，而仓库存在于 Registry 中。

默认的 Registry 是由 Docker 公司运营的公用 Registry 服务，即 Docker Hub。

Docker Hub 中有两种类型的仓库：

* 用户仓库（user repository）：由 Docker 用户创建的，用户仓库的命名由用户名和仓库名两部分组成。
* 顶层仓库（top-level repository）：由 Docker 内部的人来管理的，顶层仓库只包含仓库名部分。

---

### 镜像类型

---

#### intermediate images

Docker 镜像是分多层构成的，层与层之间存在继承关系。所有的 Docker 文件系统层默认存储在 /var/lib/docker/graph 目录，Docker 称其为图形数据库。

比如通过命令 docker pull fedora 拉去镜像时，除了会下载 fedora:latest 层，还会下载一个匿名的`<none>:<none>`中间层镜像，可以通过-a查看这些中间层。因此，通过 docker images -a 命令看到的`<none>:<none>`镜像表示 intermediate images。

#### dangling images

在Java或Golang等编程语言中，悬空的内存块是一个未被任何代码引用的内存块。这些语言的垃圾收集系统会定期标记悬空块并将其返回堆中，以便这些内存块可用于将来的分配。类似地，Docker中的悬空文件系统层是未使用的并且未被任何镜像引用。因此，我们需要一种Docker机制来清除这些悬空图像。dangling images的产生是由于docker pull或build命令，重新构建镜像时候依赖的镜像层发生改变，导致旧的镜像层变为dangling images。

因此，通过docker images命令看到的`<none>:<none>`镜像表示dangling images。

```shell
#删除dangling images镜像
docker rmi $(docker images -f "dangling=true" -q)
```

### 镜像标签

为了区分同一个仓库中的不同镜像，Docker 提供了一种称为标签的功能，这种机制使得同一个镜像仓库中可以存储多个镜像。每个镜像在列出来时都带有一个标签，每个标签对组成特定镜像的一些镜像层进行标记（比如：ubuntu:14.04、ubuntu:16.04、ubuntu:18.04）。如果没有指定具体的镜像标签，那么Docker会自动下载lastest标签的镜像。

### 构建镜像

1.编写Dockfile文件

```dockerfile
FROM ubuntu:16.04
```

2.执行构建命令

由于Docker构建镜像的过程会将中间镜像缓存，再次进行构建时，会直接从最后一次成功的中间镜像开始继续构建。可以通过--no-cache标志强制Docker忽略缓存的中间镜像，从头开始构建。

```shell
sudo docker build -t="kayvita/static_web" .
```

3.构建失败处理

如果build失败，利用最后一次成功的中间镜像进行调试，最后一次构建成功的镜像为b3b7ff88db3b。

```shell
sudo docker run -t -i b3b7ff88db3b /bin/bash
```

4.查看构建成功的镜像

```shell
sudo docker images
```

### 发布镜像

1.登录Docker Registry

```shell
docker login -u username
```

2.为镜像添加 tag

```shell
docker tag SOURCE_IMAGE[:TAG] TARGET_IMAGE[:TAG]
docker tag friendlyhello username/get-started:tag1
```

3.上传镜像至 Docker Registry

```shell
docker push username/get-started:tag1
```

4.使用 Docker Registry 镜像

```shell
docker run -p 4000:80 username/get-started:tag1
```

### 参考资料

[http://www.projectatomic.io/blog/2015/07/what-are-docker-none-none-images/][1]{:target="_blank"}

[1]:http://www.projectatomic.io/blog/2015/07/what-are-docker-none-none-images/