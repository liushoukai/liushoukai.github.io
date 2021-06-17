---
layout: post
title: linux-array
categories: linux-shell
tags: linux shell
---

## 索引数组

```shell
array_var=(1 2 3 4 5 6)
# 打印所有元素
echo ${array_var[*]}
# 打印数组长度
echo ${#array_var[*]}
```

## 关联数组

```shell
declare -A map_array
map_array=([name]='kay' [age]=26 [address]='GuangZhou')
# 当个元素
echo ${map_array['name']}
# 索引列表
echo ${!map_array[*]}
# 值列表
echo ${map_array[*]}
```

## 遍历数组

```shell
for data in ${array[@]};do
    echo ${data}
done
```
