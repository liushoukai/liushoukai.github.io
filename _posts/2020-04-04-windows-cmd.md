---
layout: post
title: windows-cmd
categories: windows
tags: cmd
---

### chcp

chcp用于设置控制台编码格式

- 936          简体中文(GB2312)
- 65001        Unicode(UTF-8)

### copy

```cmd
copy /b a.jpg+b.jpg new.jpg
```

### errorlevel

```cmd
<!-- 如果返回的错误码值大于或等于0的时候触发 -->
IF ERRORLEVEL 0 (
     echo "hello world"
)
<!-- 如果返回的错误码值等于0的时候触发 -->
IF %ERRORLEVEL% == 0 (
     echo "hello world"
)
```

### mklink

```cmd
MKLINK Link Target    # 创建指向文件的符号链接
MKLINK /D Link Target # 创建指向文件夹的符号链接
MKLINK /J Link Target # 创建指向文件夹的软链接(联接)
MKLINK /H Link Target # 创建指向文件的硬链接

J:\bin>mklink /j php "J:/bin/php-5.6.30-Win32-VC11-x64"
为 php <<===>> J:/bin/php-5.6.30-Win32-VC11-x64 创建的联接
```


### nslookup

通过nslookup判断DNS解析故障

1. 通过"开始->运行->输入cmd"，进入命令行模式
2. 输入nslookup命令后回车，将进入DNS解析查询界面
3. 命令行窗口会显示当前系统所使用的DNS服务器地址
4. 输入站点对应的域名，如"www.baidu.com",会显示解析后的IP地址

```cmd
> www.baidu.com
Server:  UnKnown
Address:  172.26.9.10

Non-authoritative answer:
Name:    www.a.shifen.com
Addresses:  112.80.248.73
          112.80.248.74
Aliases:  www.baidu.com
````

### setx

```cmd
默认在用户环境中设置此变量 ，通过/M参数指定在系统环境中设置此变量
setx CLASSPATH . /M
setx path "%path%;C:\Program Files\Java\jdk1.7.0_80\bin;" /M
```
