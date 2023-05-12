---
layout: post
title: linux-if-for-while-case
categories: linux-shell
tags: if for while case
---

```shell
if
-eq =
-gt >
-lt <
-ge >=
-le <=
-f 文件是否存在
-x 给定变量包含的文件可执行
-d 目录是否存在
-w 可写
-r 可读
-L 链接是否存在
-b 块设备

标准语法
使用字符串比较时，最好用双中括号，因为采用单个中括号可能产生错误，应避免
if [[ $age -eq 1 ]]; then
    echo 1;
elif [[ $age -eq 2 ]]; then
    echo 2;
else
    echo 'unkown';
fi

if [[ -n $cond1 ]] && [[ -z $cond2 ]]; then
    ...
fi

# 判断是否为超级用户
if [ $UID -eq 0 ];then
  echo Root user
fi

# for循环语法
for name in {a..z}.txt; do
  touch $name
done

for((i=0;i<10;i++))
{
  echo $i;
}

x=0
until [ $x -eq 9 ]; do
  let x++;
  echo $x
done

# while循环
i=1
while [ $i -le 100 ]; do
  let i++;
done
echo $i

cat test.txt | (while read line;do echo $line; done;)
while read line; do echo $line; done<./test.txt

# case
case expression in
    pattern1 )
        statements ;;
    pattern2 )
        statements ;;
    ...
esac
```

# 参考资料
https://www.cnblogs.com/kaishirenshi/p/9729800.html
