---
layout: post
title: linux-random
categories: linux-shell
tags: shell random
---

## Linux系统产生随机数

/dev/random 和 /dev/urandom 是Linux系统中提供的随机伪设备，这两个设备的任务，提供永不为空的随机字节数据流。很多解密程序与安全应用程序（如SSH Keys,SSL Keys等）需要它们提供的随机数据流。

这两个随机伪设备备的差异在于：

- /dev/random 的 random pool依赖于系统中断，在系统的中断数不足时设备会一直封锁，尝试读取的进程就会进入等待状态，直到系统的中断数充分够用，从而保证数据的随机性；
- /dev/urandom 不依赖系统的中断，也就不会造成进程忙等待，但是数据的随机性也不高；


```shell
$> ls -alF /dev/*random
crw-rw-rw-  1 root  wheel  0x11000000  8 29 17:49 /dev/random
crw-rw-rw-  1 root  wheel  0x11000001  8 24 14:58 /dev/urandom

# 用于从随机设备中读取一行数据流并转换为十六进制后查看
$> cat /dev/urandom | od -x  | head -n 1
```

## JVM使用Linux随机数

作为一个 JVM 属性，我们可以使用 java.security.egd 来影响 SecureRandom 类的初始化方式。

在启动 JVM 时，我们在命令行中使用 -D 参数声明它:

```shell
java -Djava.security.egd=file:/dev/urandom
```
