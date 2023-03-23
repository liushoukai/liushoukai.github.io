---
layout: post
title: regex
categories: regex
tags: snippets
---


`去除文本中的HTML标签`

```c
REGULAR EXPRESSION
/<[^>]*>/g

TEST STRING
<html>最近在用盒子添加物品的时候，看见下界反应核，我想起了以前的版本，所以打算玩一下<a href="mcbox://800/4">#生存狂人#</a><br/><img src='http://img3.tuboshu.com/images/mc_tie_image/201609/21/1474466431777/201609212200312096_360.jpeg'/></html>
```

`匹配英文逗号分隔的数字字符串`
```c
REGULAR EXPRESSION
/^(\d+[,])*(\d+)$/

TEST STRING
12,234,56778,3231
```


`匹配不捕获分组`

```c
REGULAR EXPRESSION
捕获分组：industr(y)
忽略分组：industr(?:y)

TEST STRING
industry
```



