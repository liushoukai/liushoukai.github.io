---
layout: post
title: linux-find-args
categories: linux-shell
tags: find args
---

# find

## 查找
```shell
# 查找当前目录下所有目录(-i 不区分大小写)
find . -iname inFo.txt
find . -iname "*.log" -o -iname "*.log.gz"
find . \( -iname "*.log" -o -iname "log.*" \)
find . -regex ".*/[0-9]+@qq.com$"
find . -iregex '.*/licen.+'
find . -path "*lib*"
find . ! -name "*.log"
find . -maxdepth 2 -name "a.sh"
find . -type s -regex ".*/php5-fpm.sock"

# 查找五分钟内访问/修改/变化过的文件
find . -type f -amin -5 
find . -type f -mmin-5
find . -type f -cmin -5

# 查找比info.txt修改时间更长的文件
find . -type f -newer ./info.txt                 

# 查找大于2KB的文件
find . -type f -size +2k
```

## 替换
```shell
# 统一转换为Unix换行符
find . -name "*.java" | xargs -I {} dos2unix {}
```

## 删除
```shell
# 删除当前目录下的空文件
find . -empty -type f | xargs -I {} rm {}

# 删除查找到的文件
find . -type f -regex ".*/*.log$" -delete

# 查找当前目录下所有目录，并删除
find . -mindepth 1 -maxdepth 1 -type d|awk 'NR<10 {print $1}'|xargs -I {} rm -rf {}
```

## 执行
```shell
# 查找十天前修改过的文件并移动至target目录中
find . -type f -iregex ".*/*.gz$" -mtime +10 -exec mv {} target \;
# 查找非www-data用户的文件并修改文件所属的用户及用户组
find . -type f ! -user www-data -exec chown www-data:www-data {} \;
# 查找文件并将内容输出到指定文件
find . -type f -regex ".*/*.php$" -exec cat {} \; > all_php_files.txt
# 查找没有设置好执行权限的PHP文件并打印
find /data/php/sattan-php/ -type f -regex ".*/*.php$" ! -perm 644 -print

# 注意：-exec参数只能接受单个命令，多个命令可以先写入shell脚本中，然后在-exec中使用这个脚本-exec ./script.sh {} \;
```

# args

```shell
cat data.txt | xargs -dX -n2

# 如何批量删除Redis中的指定的键
redis-cli keys "*" | xargs -I {} redis-cli del {}

# 防止文件名中包含空格字符
find . ! -path ".git" -name "*.txt" -print0 | xargs -n1 -0

# -I用来指定一个引用变量，在后续的语句用可以使用该变量进行操作
cat example.txt | xargs -0 -n 2 -I {} echo -n -e "\e[1;33m{}\e[0m";
```