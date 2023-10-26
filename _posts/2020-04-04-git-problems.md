---
layout: post
title: Git问题
categories: git
tags: git-command
---

## fatal: refusing to merge unrelated histories

### 问题背景

在本地初始化了一个Git代码仓库，关联到Github上新建的仓库，第一次执行git pull origin master 拉取远程分支时，出现标题上的问题（Git 2.9之后的版本才会出现此问题）。

### 原因分析

"git merge" used to allow merging two branches that have no common base by default, which led to a brand new history of an existing project created and then get pulled by an unsuspecting maintainer, which allowed an unnecessary parallel history merged into the existing project. The command has been taught not to allow this by default, with an escape hatch "--allow-unrelated-histories" option to be used in a rare event that merges histories of two projects that started their lives independently（stackoverflow）.

### 解决方法

在git pull origin master后面跟上参数--allow-unrelated-histories，如：git pull origin master --allow-unrelated-histories
