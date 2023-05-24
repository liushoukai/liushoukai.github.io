---
layout: post
title: git
categories: git
tags: git
---

# GIT命令

`git config`
```shell
# 项目配置（.git/config）
git config --edit
# 用户配置（~/.gitconfig）
git config --global --edit
# 系统配置（/etc/gitconfig）
git config --system --edit

git config --global user.name "****"
git config --global user.email "******@gmail.com"
git config --global --list
git config --global core.editor emacs
git config --global merge.tool vimdiff
git config --global http.proxy "socks5:127.0.0.1:1080"
```

`git help`
```shell
# 查看具体的COMMAND或GUIDE
git help [COMMAND|GUIDE]
# 列出Git所有COMMAND
git help -a
# 列出Git所有GUIDE
git help -g
```

`git remote`
```shell
# 删除远程仓库配置
git remote rm origin
# 新增远程仓库配置
git remote add origin git@github.com:USERNAME/REPOSITORY.git
# 替换远程仓库配置
git remote set-url origin git@github.com:USERNAME/REPOSITORY.git
# 更新本地仓库中的远程分支列表（git branch -av），用于远程分支被删除的情况 
git remote update origin --prune
```

`git clean`
```shell
# 删除本地未跟踪代码（模拟删除）
git clean -dxn
# 删除本地未跟踪代码（实际删除）
git clean -dxf
```

`git merge`
```shell
# 禁用fast-forward
git merge --no-ff
# 撤销分支合并（合并过程中不想合并了）
git merge --abort
```

`git stash`
```shell
# 查看stash
git stash list
# 添加stash
git stash save 'stash name'  

# pop与apply的区别
# 使用stash@{0]中的内容，将其应用到工作目录，然后从stash中出栈
git stash pop stash@{0}
# 使用stash@{0]中的内容，将其应用到工作目录
git stash apply stash@{0}    
# 注意：git stash pop stash@{0}等价于git stash apply stash@{0} + git stash drop stash@{0}命令；
```

`git submodule`
```shell
git submodule init
git submodule update --recursive —remote
```

# git强制推送
将项目A的代码推送到项目B的仓库，并且需要保留项目A历史的GIT提交记录；
```shell
git remote rm 
git remote add origin git@git.***.cn:*****/*****.git
git remote -av
git push origin master -u -f
```

# git克隆远程指定分支
```shell
# git克隆远程指定分支
git clone -b dev_hlct username@192.168.56.100:aiotrade.git

# 创建远程分支的本地跟踪分支
git checkout -b experimental origin/experimental
```

# git删除本地/远程分支
```shell
# 查看远程分支 
git ls-remote idc 

# 删除远程dev_hlct分支
git push idc :dev_hlct

# 删除本地dev_hlct分支
git branch -d dev_hlct
```

# 关联远程分支
```shell
# 1、已经存在的本地分支关联远程分支
git branch --set-upstream-to=origin/remoteBranch localBranch
# 2、推送本地分支时关联远程分支
git push -u origin localBranch
# 3、创建本地分支时建立追踪关系
git checkout -b localBranch origin/remoteBranch
# 查看追踪关系
git branch -vv
```

# git安装升级

`Centos安装Git`
```shell
# 1.安装依赖
yum install curl-devel expat-devel gettext-devel openssl-devel zlib-devel gcc perl-ExtUtils-MakeMaker

# 2.卸载Centos6.5自带的git1.7.1
yum remove git

# 3.下载git最新版本
cd /tmp/
wget https://www.kernel.org/pub/software/scm/git/git-2.7.2.tar.gz
sudo ln -s /data/service/git-2.7.2
tar xzvf git-2.7.2.tar.gz

# 4.安装git并添加到环境变量中
cd git-2.7.2
make prefix=/usr/local/git all
make prefix=/usr/local/git install
echo "export PATH=$PATH:/usr/local/git/bin" >> /etc/profile
source /etc/profile

# 5.查看版本号
git --version
git version 2.7.2
```