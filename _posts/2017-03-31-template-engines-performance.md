---
layout: post
title:  Java模板引擎性能对比
categories: java
tags: java template
---

# 模板引擎性能对比

从Github上翻到对JSP、Thymeleaf 3、Velocity 1.7、Freemarker 2.3.23几款主流模板的性能对比，总体上看，Freemarker、Velocity、JSP在性能上差别不大，而
Thymeleaf与前三者相比，在性能上存在较大的差距，因此，选择Thymeleaf作为模板引擎需要慎重。
参考：https://github.com/jreijn/spring-comparing-template-engines/issues/19

## System Configuration
```
Architecture: x86_64
CPU op-mode(s): 32-bit, 64-bit
Byte Order: Little Endian
CPU(s): 4
On-line CPU(s) list: 0-3
Thread(s) per core: 2
Core(s) per socket: 2
Socket(s): 1
NUMA node(s): 1
Vendor ID: GenuineIntel
CPU family: 6
Model: 37
Model name: Intel(R) Core(TM) i5 CPU M 430 @ 2.27GHz
Stepping: 2
CPU MHz: 1199.000
CPU max MHz: 2267.0000
CPU min MHz: 1199.0000
BogoMIPS: 4522.04
Virtualization: VT-x
L1d cache: 32K
L1i cache: 32K
L2 cache: 256K
L3 cache: 3072K
NUMA node0 CPU(s): 0-3
```

## `JSP`
```
Document Path: /jsp
Document Length: 8515 bytes
Concurrency Level: 25
Time taken for tests: 13.003 seconds
Complete requests: 25000
Failed requests: 0
Keep-Alive requests: 0
Total transferred: 218825000 bytes
HTML transferred: 212875000 bytes
Requests per second: 1922.59 (#/sec) (mean)
Time per request: 13.003 (ms) (mean)
Time per request: 0.520 (ms) (mean, across all concurrent requests)
Transfer rate: 16434.05 (Kbytes/sec) received
```

## `Thymeleaf 3`
```
Document Path: /thymeleaf
Document Length: 8849 bytes
Concurrency Level: 25
Time taken for tests: 23.303 seconds
Complete requests: 25000
Failed requests: 0
Keep-Alive requests: 0
Total transferred: 225300000 bytes
HTML transferred: 221225000 bytes
Requests per second: 1072.80 (#/sec) (mean)
Time per request: 23.303 (ms) (mean)
Time per request: 0.932 (ms) (mean, across all concurrent requests)
Transfer rate: 9441.52 (Kbytes/sec) received
```

## `Velocity 1.7`
```
Document Path: /velocity
Document Length: 8951 bytes
Concurrency Level: 25
Time taken for tests: 13.200 seconds
Complete requests: 25000
Failed requests: 0
Keep-Alive requests: 0
Total transferred: 227975000 bytes
HTML transferred: 223775000 bytes
Requests per second: 1893.92 (#/sec) (mean)
Time per request: 13.200 (ms) (mean)
Time per request: 0.528 (ms) (mean, across all concurrent requests)
Transfer rate: 16865.88 (Kbytes/sec) received
```

## `Freemarker 2.3.23`
```
Document Path: /freemarker
Document Length: 9035 bytes
Concurrency Level: 25
Time taken for tests: 12.988 seconds
Complete requests: 25000
Failed requests: 0
Keep-Alive requests: 0
Total transferred: 230075000 bytes
HTML transferred: 225875000 bytes
Requests per second: 1924.83 (#/sec) (mean)
Time per request: 12.988 (ms) (mean)
Time per request: 0.520 (ms) (mean, across all concurrent requests)
Transfer rate: 17299.01 (Kbytes/sec) received
```
