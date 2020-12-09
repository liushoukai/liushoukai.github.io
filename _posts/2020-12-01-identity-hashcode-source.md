---
layout: post
title: 标识哈希码源码分析
categories: java
tags: java
---

### 标识哈希码(identity hash code)

在Java一般使用obj.hashCode()来代表对象的地址，但是两个相同的对象就不行了，两个相同的对象的hashcode是相同的。
因此，如果要对比两个相同的对象的地址可以使用 System.identityHashCode(obj)。

标识哈希码(identity hash code)
标识哈希码是一个对象身份的唯一标识，对象的标识哈希码可以通过 obj.hashCode() 或 System.identityHashCode(obj) 方法获取。

标识哈希码的特点：

1. 一个对象在其生命期中标识哈希码是保持不变的；
2. 如果两个对象引用的相等，即：a == b，那么两个对象的 System.identityHashCode(obj) 必定相等；
3. 那么两个对象的 System.identityHashCode(obj) 不相等，那他们必定不是同一个对象；
4. 如果 System.identityHashCode(obj) 相等的话，由于存在HASH冲突，所以并不能保证 a == b；

---

### System.identityHashCode(obj)

identityHashCode是System里面提供的本地方法，java.lang.System#identityHashCode。

```java
/**
 * Returns the same hash code for the given object as
 * would be returned by the default method hashCode(),
 * whether or not the given object's class overrides
 * hashCode().
 * The hash code for the null reference is zero.
 *
 * @param x object for which the hashCode is to be calculated
 * @return  the hashCode
 * @since   JDK1.1
 */
public static native int identityHashCode(Object x);
```

identityHashCode 返回对象的哈希码，与对象默认的 hashCode() 方法返回的哈希码一样，null 引用的哈希吗为 0。

identityHashCode 和 hashCode 的区别是，`无论给定对象的类是否重写 hashCode() 方法，identityHashCode 的返回值都和默认的 hashCode() 方法返回的哈希码一样`。
