---
layout: post
title: HashMap源码分析
categories: java
tags: java
---

## 场景描述

最近，项目中常常见到类似下面的一段代码，即在初始化HashMap容量的时候，将插入HashMap的元素数量除以`0.75f`（即乘以4/3），从而防止插入元素数量大于HashMap默认初始容量DEFAULT_INITIAL_CAPACITY=16对应阈值而导致的扩容；

```java
Map<Integer, MenuItem> tmpMap = new HashMap<>(menuList.size() * 4 / 3);
```

## 源码分析

查看源码发现传入的`menuList.size() * 4 / 3`被赋值给HashMap作为初始容量，默认扩容因子为`static final float DEFAULT_LOAD_FACTOR = 0.75f`。

```java
public HashMap(int initialCapacity, float loadFactor) {
  if (initialCapacity < 0)
    throw new IllegalArgumentException("Illegal initial capacity: " +
                                       initialCapacity);
  if (initialCapacity > MAXIMUM_CAPACITY)
    initialCapacity = MAXIMUM_CAPACITY;
  if (loadFactor <= 0 || Float.isNaN(loadFactor))
    throw new IllegalArgumentException("Illegal load factor: " + loadFactor);
  this.loadFactor = loadFactor;
  this.threshold = tableSizeFor(initialCapacity);
}

static final int tableSizeFor(int cap) {
  int n = cap - 1;
  n |= n >>> 1;
  n |= n >>> 2;
  n |= n >>> 4;
  n |= n >>> 8;
  n |= n >>> 16;
  return (n < 0) ? 1 : (n >= MAXIMUM_CAPACITY) ? MAXIMUM_CAPACITY : n + 1;
}
```

## 处理结论
