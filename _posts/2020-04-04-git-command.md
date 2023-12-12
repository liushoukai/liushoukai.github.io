---
layout: post
title: git
categories: git
tags: git-command
---

## 环境配置

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

## 将已经存在的代码放入仓库

```shell
cd existing_folder
git init
git remote add origin git@github.com:username/server.git
git add .
git commit . -m 'Init commit'
git branch --set-upstream-to=origin/main main
git push -u origin master
```

### 暂存区操作

```shell
git add ./node_modules/
# git add的逆操作，将已经加入暂存区的数据从暂存区移除
git rm --cached -r ./node_modules/
```

## 查看命令说明

```shell
# 查看具体的COMMAND或GUIDE
git help [COMMAND|GUIDE]
# 列出Git所有COMMAND
git help -a
# 列出Git所有GUIDE
git help -g
```

## 维护远程分支

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

## 删除本地未跟踪代码

```shell
# 删除本地未跟踪代码（模拟删除）
git clean -dxn
# 删除本地未跟踪代码（实际删除）
git clean -dxf
```

## 合并本地分支

```shell
# 禁用fast-forward
git merge --no-ff
# 撤销分支合并（合并过程中不想合并了）
git merge --abort
```

## 暂存本地改动

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

## git撤销远程分支commit

```shell
# 1.回滚本地分支，本地分支版本将落后远程分支
git reset --hard [commit]
# 2.必须使用强制推送-f覆盖远程分支，否则无法推送到远程分支
git push -f
```

## git强制推送

背景：将项目A的代码推送到项目B的仓库，并且需要保留项目A历史的提交记录；

```shell
git remote rm 
git remote add origin git@git.***.cn:*****/*****.git
git remote -av
git push origin master -u -f
```

## git克隆远程指定分支

```shell
# git克隆远程指定分支
git clone -b dev_hlct username@192.168.56.100:aiotrade.git

# 创建远程分支的本地跟踪分支
git checkout -b experimental origin/experimental
```

## git删除本地/远程分支

```shell
# 查看远程分支 
git ls-remote idc 

# 删除远程dev_hlct分支
git push idc :dev_hlct

# 删除本地dev_hlct分支
git branch -d dev_hlct
```

## 关联远程分支

```shell
# 已经存在的本地分支关联远程分支
git branch --set-upstream-to=origin/remoteBranch localBranch
# 推送本地分支时关联远程分支
git push -u origin localBranch
# 创建本地分支时关联远程分支
git checkout -b localBranch origin/remoteBranch
# 查看关联关系
git branch -vv
```

## git安装升级

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

## git添加空目录

创建空文件并添加到Git进行管理的方法是在目录中创建一个.gitignore文件，内容如下：

```shell
# Ignore everything in this directory
*
# Except this file
!.gitignore
```

## git大文件存储LFS

```shell
# 安装git-lfs扩展
git lfs install

# 添加git-lfs处理的文件后缀
git lfs track "*.psd"

# 添加.gitattributes文件到暂存区
git add .gitattributes

# 其他步骤同使用Git相同
git add file.psd
git commit -m "Add design file"
git push origin master
```

## git reset与checkout区别

`HEAD`
HEAD 是当前分支引用的指针，它总是指向该分支上的最后一次提交。 这表示 HEAD 将是下一次提交的父结点。通常，理解 HEAD 的最简方式，就是将它看做 你的上一次提交 的快照。

`Index`
索引是你的 预期的下一次提交。 我们也会将这个概念引用为 Git 的 “暂存区域”，这就是当你运行 git commit 时 Git 看起来的样子。Git将上一次检出到工作目录中的所有文件填充到索引区，它们看起来就像最初被检出时的样子。之后你会将其中一些文件替换为新版本，接着通过 git commit 将它们转换为树来用作新的提交。

`Working Directory`
最后，你就有了自己的工作目录。 另外两棵树以一种高效但并不直观的方式，将它们的内容存储在 .git 文件夹中。 工作目录会将它们解包为实际的文件以便编辑。
你可以把工作目录当做 沙盒。在你将修改提交到暂存区并记录到历史之前，可以随意更改。

### Commit Level使用Reset

reset [commit]：命令以特定的顺序重写3棵树：

1. 移动HEAD(reset --soft [commit])：移动HEAD指向特定的位置，不会改变索引和工作目录，若指定了 --soft，则到此停止；
2. 更新索引(reset [commit])：使用HEAD指向快照的内容更新Index，若未指定 --hard，则到此停止；
3. 更新工作目录(reset --hard [commit])：使用Index强制覆盖Working Directory，被覆盖的文件将无法恢复；

### Commit Level使用Checkout

checkout [branch]与reset --hard [branch]相似，但是存在以下不同：

1. 工作目录安全性
checkout [branch]     对工作目录是安全的，它会通过检查来确保不会将已更改的文件弄丢。
reset --hard [branch] 对工作目录是不安全的，不做检查就全面地替换所有东西。
2. 影响分支的指针
假设有master和develop两个分支并且它们分别指向不同的提交，现在在develop上（所以HEAD指向它）。
如果运行git reset master，那么develop自身现在会和master指向同一个提交。
如果运行git checkout master，那么develop自身还是指向原线的提交

### File Level使用Reset

git reset file.txt实际为git reset --mixed HEAD file.txt的简写形式，因为你既没有指定一个提交的 SHA-1 或分支，也没有指定 --soft 或 —hard，所以它本质上只是将file.txt从HEAD复制到索引中，即取消暂存文件；

### File Level使用Checkout

git checkout file 会使用HEAD指向的commit填充Index中对应的文件，然后使用Index中的文件强制覆盖工作目录中的文件；
