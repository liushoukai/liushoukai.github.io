---
layout: post
title: regex
categories: regex
tags: snippets
---


```shell
# 去除文本中的HTML标签
/<[^>]*>/g

<html>最近在用盒子添加物品的时候，看见下界反应核，我想起了以前的版本，所以打算玩一下<a href="mcbox://800/4">#生存狂人#</a><br/><img src='http://img3.tuboshu.com/images/mc_tie_image/201609/21/1474466431777/201609212200312096_360.jpeg'/></html>

# 匹配英文逗号分隔的数字字符串
/^(\d+[,])*(\d+)$/

12,234,56778,3231
```

## Group
|Syntax|Description|Regular Expression|Test String|
|---|---|---|---|
|`(exp)`|`匹配exp，并捕获文本到自动命名的组里`|`/(ab)(\s\1)*/`|`ab ab ab`|
|`(?<name>exp)`|`匹配exp，并捕获文本到名称为name的组里`|`/(?<g1>ab)(\s\k<g1>)*/`|`ab ab ab`|
|`(?:exp)`|`匹配exp，不捕获匹配的文本，也不给此分组分配组号`|``|``|
|`(?=exp)`|`匹配exp前面的位置`|`/\w*(?=world)/`|`helloworld`|
|`(?<=exp)`|`匹配后面跟的不是exp的位置`|`/(?<=hello)\w*/`|`helloworld`|
|`(?!exp)`|`匹配后面跟的不是exp的位置`|`/Hello,(?!John)/g`|`Hello,John Hello,Lucy`|
|`(?<!exp)`|`匹配前面不是exp的位置`|`/(?<!(aa))cc/g`|`aacc bbcc`|
|`(?#comment)`|`提供注释辅助阅读，不对正则表达式的处理产生任何影响`|`/(?#some comment)(ab)+/`|`ababab`|

```shell
# 捕获分组：industr(y)
# 忽略分组：industr(?:y)

industry
```


