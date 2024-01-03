---
layout: post
title: nginx配置
categories: linux
tags: nginx
---

## nginx配置http跳转https

```shell
if ($scheme = http) {
    return 301 https://$host$request_uri;
}
```

如果状态码返回301或者302，当post数据到http协议时，重定向后会出现请求方法变为 get，post数据丢失。

解决这个问题就要换返回的状态码。

```shell
if ($scheme = http) {
    return 307 https://$host$request_uri;
}
```

307、308 都可以保持post数据的重定向，包括请求方法也不会变化。
307是临时，308是永久

所以当往一个http地址发送post请求，服务器重定向到https，要配置为307或者308状态码.
