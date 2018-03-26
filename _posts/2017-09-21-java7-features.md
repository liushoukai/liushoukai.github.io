---
layout: post
title:  Java7特性
categories: Java
tags: java
---

multi-catch

### 允许使用数值文字的加强
```java
int billion = 1_000_000_000;
```

### 允许在switch中使用字符串
```java
String availability = "available";
switch(availability) {}
```

### 允许使用前缀0b创建二进制文字
```java
int binary = 0b1001_1001;
```

### 集合语言简写
```java
List list = ["item"];
String item = list[0];

Set set = {"item"};

Map map = {"key" : 1};
int value = map["key"];
```


参考资料
http://code.joejag.com/2009/new-language-features-in-java-7.html
http://openjdk.java.net/projects/coin/
http://developer.51cto.com/art/201004/194814_1.htm
