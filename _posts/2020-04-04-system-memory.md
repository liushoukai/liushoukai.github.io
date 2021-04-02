---
layout: post
title: 操作系统内存
categories: system
tags: memory
---

### 操作系统内存

虚拟内存(Virtual Memory)：表示操作系统内核为了对进程地址空间进行管理而精心设计的一个逻辑意义上的内存空间。

- processA: A1+A2+A3+A4+灰色部分
- processB: B1+B2+B3+灰色部分

驻留内存(Resident Memory)：表示被映射到进程虚拟内存空间的物理内存。

- processA: A1+A2+A3+A4
- processB: B1+B2+B3

共享内存(Share Memory)：表示的是进程占用的共享内存大小。

- processA: A4
- processA: B3

为了实现虚拟内存空间到物理内存空间映射，内核会为系统中每一个进程维护一份相互独立的页映射表。页映射表的基本原理是将程序运行过程中需要访问的一段虚拟内存空间通过页映射表映射到一段物理内存空间上，这样CPU访问对应虚拟内存地址的时候就可以通过这种查找页映射表的机制访问物理内存上的某个对应的地址。其中，"页（page）"是虚拟内存空间向物理内存空间映射的基本单元。

![system-memory](/assets/img/system-memory/1.png){:width="100%"}
