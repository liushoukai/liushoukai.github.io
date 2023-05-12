---
layout: post
title: linux-dig-nslookup
categories: linux-shell
tags: dig nslookup
---

# dig

```shell
dig www.bing.com +nostats +nocomments +nocmd
# 指定域名服务器，跟踪解析过程
dig s11.qyz.dragonregion.com +trace @202.96.128.86
```

# nslookup

```shell
# NSLookup可以指定查询的类型，可以查到DNS记录的生存时间还可以指定使用那个DNS服务器进行解释。
nslookup -q=a www.bing.com
nslookup -q=mx www.bing.com
nslookup -q=cname www.bing.com
nslookup -q=ns www.bing.com
```
