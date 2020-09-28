---
layout: post
title:  ConcurrentModificationException源码分析
categories: jdk
tags: java
---

### 源码分析

AbstractList的核心属性modCount，初始值为0，表示List结构已经被修改的次数。结构修改包括改变List的大小，或以其他类似的方式导致其在迭代的过程中产生不正确的结果的行为。

```java
protected transient int modCount = 0;
```

这个属性会在iterator()方法返回的Iterator以及listIterator()方法返回的ListIterator中用到。
如果modCount的值非预期的改变，那么Iterator或ListIterator会在执行next()、remove()、previous()、set()、add()方式时，抛出ConcurrentModificationException异常。
通过这种方式，保障了在使用迭代器进行迭代的过程中，一旦List的结构被并发修改，会提供fail-fast的行为，不是非确定性的行为。

子类对该modCount的使用是可选的。如果子类系统提供一个支持fail-fast行为的迭代器，那么子类只需要在add(int, E)、remove(int)以及类似修改List结构的方法中增加modCount的值。
单次add(int, E)、remove(int)方法至多只能为modCount属性+1，否则会抛出ConcurrentModificationException异常。如果无需提供一个支持fail-fast行为的迭代器，那么子类可以忽略该属性。

在使用for循环List的时候，会调用iterator()方法返回一个`Iterator<E>`迭代器。

```java
public Iterator<E> iterator() {
    return new Itr();
}
```

Iter类包含一个expectedModCount属性，默认值与初始化时AbstractList属性中的modCount值相等。

```java
int expectedModCount = modCount;
```

每次迭代器执行next()方法时，都会先调用checkForComodification()方法，检查expectedModCount的属性值与当前AbstractList属性中的modCount值是否相等，如果不相等，则抛出ConcurrentModificationException异常。

当调用List.remove()方法时，会导致当前List的modCount++，此后，当Iterator进行下一次迭代时，检查到modCount不等于expectedModCount，所以抛出了ConcurrentModificationException异常。

```java
@Test(expected = ConcurrentModificationException.class)
public void test() {
    List<String> list = new ArrayList<>();
    list.add("a"); // modCount == 1
    list.add("b"); // modCount == 2
    for (String item : list) { // expectedModCount == 2
        if ("b".equals(item)) {
            list.remove(item); // modCount == 3
        }
    }
}
```

正确的方法

```java
@Test
public void test() {
    List<String> list = new ArrayList<>();
    list.add("a"); // modCount == 1
    list.add("b"); // modCount == 2
    Iterator<String> iterator = list.iterator();
    while (iterator.hasNext()) {
        String item = iterator.next();
        if ("b".equals(item)) {
            iterator.remove();
        }
    }
    Assert.assertEquals(1, list.size());
}
```
