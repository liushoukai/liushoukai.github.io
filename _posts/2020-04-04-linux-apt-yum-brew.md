---
layout: post
title: linux-apt-yum-brew
categories: linux-shell
tags: linux apt yum brew
---

# Homebrew

`Homebrew简介`

Homebrew 是一款Ruby开发的软件包管理系统，用以简化 MacOS 系统上的软件安装过程。

`Homebrew第三方仓库Taps`

brew tap(third-party-repositories)可以为brew的软件的 跟踪,更新,安装添加更多的的tap formulae
如果你在核心仓库没有找到你需要的软件,那么你就需要安装第三方的仓库去安装你需要的软件

```shell
# 列出已经安装的仓库
brew tap
```
在本地对这个 https://github.com/user/repo 仓库上做了一个浅度的克隆，完成之后 brew就可以在这个仓库包含的formulae上工作,好比就在Homebrew规范的仓库,你可使用brew install 或者brew uninstall 安装或者卸载这个仓库上的软件。当你执行brew update这个命令时，tap 和 formulae 就会自定更新
```shell
brew tap <user>/<repo>
```
在本地对这个 URL 仓库上做了一个浅度的克隆,和上面一个参数命令是不一样的,URL没有默认关联到Github,这个URL没有要求必须是HTTP协议，任何位置和任何协议而且Git也是能很好的处理的
```shell
brew tap <user>/<repo> URL
# 删除已经安装的仓库
brew untap <user>/<repo>
```

# Homebrew安装多版本JDK
``shell
brew searck openjdk
brew install --cask adoptopenjdk8

Homebrew更换国内源
阿里云开发者社区提供了阿里云官方镜像站，为广大开发者提供了极速全面稳定的系统镜像服务。
具体更换 Homebrew 更换镜像源，详见官方文档：https://developer.aliyun.com/mirror/homebrew
0.安装cask软件安装工具
brew install cask

1、切换镜像源
```shell
# 中国科学技术大学镜像源
cd "$(brew --repo)"

# 替换brew.git
git remote set-url origin git://mirrors.ustc.edu.cn/brew.git

# 替换homebrew-core.git和homebrew-cask.git
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
git remote set-url origin git://mirrors.ustc.edu.cn/homebrew-core.git
cd "$(brew --repo)/Library/Taps/caskroom/homebrew-cask"
git remote set-url origin https://mirrors.ustc.edu.cn/homebrew-cask.git

# 应用生效
brew update
```

2、默认镜像源
```shell
cd "$(brew --repo)"
git remote set-url origin https://github.com/Homebrew/brew.git
cd "$(brew --repo)/Library/Taps/homebrew/homebrew-core"
git remote set-url origin https://github.com/Homebrew/homebrew-core.git
cd "$(brew --repo)/Library/Taps/caskroom/homebrew-cask"
git remote set-url origin https://github.com/Homebrew/homebrew-cask.git

# 应用生效
brew update
```

3、终端替换homebrew-bottles配置
```shell
Bash :
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew/homebrew-bottles' >> ~/.bash_profile
source ~/.bash_profile

Zsh
echo 'export HOMEBREW_BOTTLE_DOMAIN=https://mirrors.ustc.edu.cn/homebrew/homebrew-bottles' >> ~/.zshrc
source ~/.zshrc
```

# Homebrew配置代理
因为 brew 是支持全局代理的，我们只需要在当前环境当中加入代理配置即可，就能通过ss来更新了。
```shell
bash
echo export ALL_PROXY=socks5://127.0.0.1:1080 >> ~/.bash_profile
zsh
echo export ALL_PROXY=socks5://127.0.0.1:1080 >> ~/.zsh_profile
```

# Homebrew命令
```shell
# 检查Homebrew是否正常
brew doctor

# 搜索软件包
brew search gpg2

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
brew tap                     list tapped repositories
brew tap <tapname>           add tap
brew untap <tapname>         remove a tap
```

# Homebrew安装minikube
```shell
# 升级 minikube 版本
brew upgrade minikube
brew link minikube
```

Homebrew安装thrift
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


use brew extract to stable tap on GitHub
You create a local “tap” - which I assume is something like a local brew repository
You extract the desired version of the package into this local tap
You install your local tap
use $USER variable to mimick userName/repoName structure

this does not actually create any git repositories

# create a new tap

brew tap-new $USER/local-thrift

# extract into local tap

brew extract --version=0.9.3 thrift $USER/local-thrift

# run brew install@version as usual

brew install thirft@0.9

echo 'export PATH="/usr/local/opt/thrift@0.9/bin:$PATH"' >> ~/.zshrc

source ~/.zshrc

thrift --version
```

# Homebrew安装php
```shell
Up until the end of March 2018, all PHP related brews were handled by Homebrew/php tab, but that has been deprecated, so now we use what’s available in the Homebrew/core package. This should be a better maintained, but is a much less complete, set of packages.
Both PHP 5.6 and PHP 7.0 has been deprecated and removed from Brew because they are out of support, and while it’s not recommended for production, there are legitimate reasons to test these unsupported versions in a development environment.
Remember only PHP 7.1 through 7.3 are officially supported by Brew so if you want to install PHP 5.6 or PHP 7.0 you will need to add this tap: brew tap exolnet/homebrew-deprecated

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

# Homebrew安装java
```shell
# 安装JDK
brew update
brew cask install java
brew <command> --cask

# 列出所有已安装的JDK版本
/usr/libexec/java_home -V

# 修改~/.profile设置JAVA_HOME环境变量
JAVA_HOME=$(/usr/libexec/java_home)
export JAVA_HOME
```

# 安装Oracle JDK
```shell
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

brew install --cask adoptopenjdk8

$ ll /usr/libexec/java_home

lrwxr-xr-x  1 root  wheel  79 11 23  2019 /usr/libexec/java_home@ -> /System/Library/Frameworks/JavaVM.framework/Versions/Current/Commands/java_home

$ /usr/libexec/java_home -VMatching Java Virtual Machines (5):

    1.8.0_271, x86_64:    "Java SE 8"    /Library/Java/JavaVirtualMachines/jdk1.8.0_271.jdk/Contents/Home

    1.8.0_171, x86_64:    "Java SE 8"    /Library/Java/JavaVirtualMachines/jdk1.8.0_171.jdk/Contents/Home

    1.8.0_131, x86_64:    "Java SE 8"    /Library/Java/JavaVirtualMachines/jdk1.8.0_131.jdk/Contents/Home

    1.8.0_111, x86_64:    "Java SE 8"    /Library/Java/JavaVirtualMachines/jdk1.8.0_111.jdk/Contents/Home

    1.8.0_40, x86_64:    "Java SE 8"    /Library/Java/JavaVirtualMachines/jdk1.8.0_40.jdk/Contents/Home
```

# APT
```shell
# APT仓库源管理
sudo sed -i'.bak' "s/us.archive/cn.archive/g" /etc/apt/sources.list

# 删除更新
sudo rm /etc/apt/sources.list.d/docker.list

# Dpkg软件包安装
dpkg -i package-file-name.deb

# Apt删除包及其配置
dpkg -l | grep -i docker
sudo apt-get purge -y docker-ce docker-ce-cli
sudo apt-get autoremove -y --purge docker-ce docker-ce-cli

# Apt软件安装
sudo apt update
sudo apt upgrade
sudo apt install -y vim openssh-server git lrzsz curl expect pinfo htop pinfo build-essential openssh-server python-dev cmake tree

# 发行版包管理
yum -y install python-devel
apt -y install python-dev

# 软件包降级
sudo apt install libuuid1=2.27.1-6ubuntu3

# 使用aptitude安装软件（注意⚠️：使用aptitude可以自动处理包降级冲突）
sudo apt install aptitude
sudo aptitude install myNewPackage

# 查询软件包依赖关系
正向依赖：apt-cache depends libphp-jabber
反向依赖：apt-cache rdepends php5
```

# PPA
`PPA介绍`

PPA 表示 个人软件包存档(Personal Package Archive)。PPA可以理解为是一个包含软件信息的网址。
当你运行 sudo apt update 命令时，你的系统将使用 APT工具 来检查软件仓库并将软件及其版本信息存储在缓存中。当你使用 sudo apt install package_name 命令时，它通过该信息从实际存储软件的网址获取该软件包。

`PPA用途`

 假设有人开发了一款软件，并希望 Ubuntu 将该软件包含在官方软件仓库中。在 Ubuntu 做出决定并将其包含在官方存软件仓库之前，如何使终端用户安装软件？
Ubuntu 提供了一个名为 Launchpad 的平台，使软件开发人员能够创建自己的软件仓库。终端用户，也就是你，可以将 PPA 仓库添加到 sources.list 文件中，当你更新系统时，你的系统会知道这个新软件的可用性，然后你可以使用标准的 apt 命令安装它。
```shell
# 查看PPA
ls -alF /etc/apt/sources.list.d/

# 通过PPA安装软件
sudo add-apt-repository ppa:dr-akulavich/lighttable
sudo apt-get update
sudo apt-get install lighttable-installer

# 删除PPA安装软件
sudo add-apt-repository --remove ppa:dr-akulavich/lighttable
```

# 参考资料
* [https://developer.aliyun.com/mirror/homebrew][1]{:target="_blank"}
* [https://blog.csdn.net/aa464971/article/details/84860937][2]{:target="_blank"}
* [https://cmichel.io/how-to-install-an-old-package-version-with-brew/][3]{:target="_blank"}

[1]:https://developer.aliyun.com/mirror/homebrew
[2]:https://blog.csdn.net/aa464971/article/details/84860937
[3]:https://cmichel.io/how-to-install-an-old-package-version-with-brew/
