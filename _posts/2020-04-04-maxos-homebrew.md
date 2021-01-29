---
layout: post
title: Homebrew 使用
categories: tools
tags: homebrew macOS
---

### Homebrew 简介

---

Homebrew 是一款自由及开放源代码的软件包管理系统，用以简化 macOS 系统上的软件安装过程。

它拥有安装、卸载、更新、查看、搜索等很多实用的功能，通过简单的一条指令，就可以实现包管理，十分方便快捷。

### Homebrew 更换镜像

---

阿里云开发者社区提供了阿里云官方镜像站，为广大开发者提供了极速全面稳定的系统镜像服务。

具体更换 Homebrew 更换镜像源，详见官方文档：[https://developer.aliyun.com/mirror/homebrew][1]{:target="_blank"}

---

### Homebrew 配置代理

---

因为 brew 是支持全局代理的，我们只需要在当前环境当中加入代理配置即可，就能通过 ss 来更新了。

``` shell
# bash
echo export ALL_PROXY=socks5://127.0.0.1:1080 >> ~/.bash_profile

# zsh
echo export ALL_PROXY=socks5://127.0.0.1:1080 >> ~/.zsh_profile
```

---

### Homebrew 命令

---

```shell
# 检查Homebrew是否正常
brew doctor

# 搜索软件包
Brew search gpg2

# 查看软件包
brew list –l
brew info mysql

# 安装/卸载软件包
brew install mysql
brew rm/remove/uninstall mysql

# 清理安装包缓存
brew cleanup

# 管理软件包
brew services list
brew services start mysql
brew services restart mysql
brew services stop mysql

# 升级所有可以升级的软件们
brew upgrade

# 添加第三方仓库
brew tap                     # list tapped repositories
brew tap <tapname>           # add tap
brew untap <tapname>         # remove a tap
```

---

### Homebrew 安装多版本 minikube

---

升级 minikube 版本

```shell
brew upgrade minikube
brew link minikube
```

---

### Homebrew 安装多版本 thrift

---

```shell
brew install https://raw.githubusercontent.com/Homebrew/homebrew-core/42d7c1d6924d08c3f70f32aba87a7f2c795fd487/Formula/thrift@0.9.rb

==> thrift@0.9
thrift@0.9 is keg-only, which means it was not symlinked into /usr/local,
because this is an alternate version of another formula.
If you need to have thrift@0.9 first in your PATH run:
  echo 'export PATH="/usr/local/opt/thrift@0.9/bin:$PATH"' >> ~/.bash_profile
For compilers to find thrift@0.9 you may need to set:
  export LDFLAGS="-L/usr/local/opt/thrift@0.9/lib"
  export CPPFLAGS="-I/usr/local/opt/thrift@0.9/include"
For pkg-config to find thrift@0.9 you may need to set:
  export PKG_CONFIG_PATH="/usr/local/opt/thrift@0.9/lib/pkgconfig"

echo 'export PATH="/usr/local/opt/thrift@0.9/bin:$PATH"' >> ~/.bash_profile
```

---

### Homebrew 安装多版本 php

---

Up until the end of March 2018, all PHP related brews were handled by Homebrew/php tab, but that has been deprecated, so now we use what's available in the Homebrew/core package. This should be a better maintained, but is a much less complete, set of packages.

Both PHP 5.6 and PHP 7.0 has been deprecated and removed from Brew because they are out of support, and while it's not recommended for production, there are legitimate reasons to test these unsupported versions in a development environment.

Remember only PHP 7.1 through 7.3 are officially supported by Brew so if you want to install PHP 5.6 or PHP 7.0 you will need to add this tap:
`brew tap exolnet/homebrew-deprecated`

```shell
brew install php@5.6
brew install php@7.0
brew install php@7.1
brew install php@7.2
brew install php@7.3

/usr/local/etc/php/5.6/php.ini 
/usr/local/etc/php/7.0/php.ini 
/usr/local/etc/php/7.1/php.ini 
/usr/local/etc/php/7.2/php.ini 
/usr/local/etc/php/7.3/php.ini

brew install php@7.1
brew unlink php && brew link --force php@7.1
brew unlink php@7.3 && brew link --force --overwrite php@5.6

echo 'export PATH="/usr/local/opt/php@7.2/bin:$PATH"' >> ~/.bash_profile
echo 'export PATH="/usr/local/opt/php@7.2/sbin:$PATH"' >> ~/.bash_profile
```

---

### Homebrew 安装多版本 java

---
```shell
1.安装JDK
brew update
brew cask install java

2.列出所有已安装的JDK版本
/usr/libexec/java_home -V

3.修改~/.profile设置JAVA_HOME环境变量
JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_HOME

安装Oracle JDK
https://www.oracle.com/java/technologies/javase/javase8-archive-downloads.html

Install homebrew
/usr/bin/ruby -e "$(curl -fsSL https://raw.githubusercontent.com/Homebrew/install/master/install)"

Update homebrew if already installed:
brew update

allow brew to lookup versions
brew tap homebrew/cask-versions

list available java versions
brew search java

Optional: to find out the minor version of java

brew cask info java8

install java 8 (or any other version available)
brew cask install java8


$ ll /usr/libexec/java_home
lrwxr-xr-x  1 root  wheel  79 11 23  2019 /usr/libexec/java_home@ -> /System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java_home


$ /usr/libexec/java_home -VMatching Java Virtual Machines (5):
    1.8.0_271, x86_64:    "Java SE 8"    /Library/Java/JavaVirtualMachines/jdk1.8.0_271.jdk/Contents/Home
    1.8.0_171, x86_64:    "Java SE 8"    /Library/Java/JavaVirtualMachines/jdk1.8.0_171.jdk/Contents/Home
    1.8.0_131, x86_64:    "Java SE 8"    /Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home
    1.8.0_111, x86_64:    "Java SE 8"    /Library/Java/JavaVirtualMachines/jdk1.8.0_111.jdk/Contents/Home
    1.8.0_40, x86_64:    "Java SE 8"    /Library/Java/JavaVirtualMachines/jdk1.8.0_40.jdk/Contents/Home
```

### 参考资料

---

1. [https://developer.aliyun.com/mirror/homebrew][1]{:target="_blank"}
2. [https://blog.csdn.net/aa464971/article/details/84860937][2]{:target="_blank"}

[1]:https://developer.aliyun.com/mirror/homebrew
[2]:https://blog.csdn.net/aa464971/article/details/84860937
