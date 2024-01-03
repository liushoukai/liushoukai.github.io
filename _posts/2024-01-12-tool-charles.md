---
layout: post
title:  Charles抓包详解
categories: tool
tags: charles
---

## Charles不能抓包问题处理

### Charles 浏览器抓包

遇到 Mac 的网络请求不能在浏览器抓包，首先确认Charles的proxy选项设置，Proxy -> macOS Proxy，勾选上macOS Proxy，再试一试能否抓取mac的网络请求包。

### 操作系统信任Charles根证书

选择Charles菜单：`Help -> SSL Proxying -> Install Charles Root Certificate`，此时会打开mac的钥匙串访问程序，右键选择证书列表中的Charles根证书，将该证书选择永久信任。

### JDK信任Charles根证书

使用 Charles 作为 Java HttpClient 的代理抓取 https 请求时需要在 JVM 中安装证书。

选择Charles菜单：`Help -> SSL Proxying -> Install Charles Root Certificate in Java JVMs`，此时会打开系统的terminal运行`/Applications/Charles.app/Contents/Resources % ./add-to-java-cacerts.command`安装证书。

### 代理冲突导致不能抓包

代理上网方式，这可能根Charles的代理有所冲突，
解决方法是，设置 -> 网络 -> Wifi -> 高级 -> 代理，在左侧的配置协议列表中取消勾选"自动发现代理"和"自动代理配置"。
重启Charles，再尝试一下，看能否Charles抓取mac的网络请求包。
